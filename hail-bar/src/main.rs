use chrono::{DateTime, Local};
use core::option::Option::Some;
use iced::border::Radius;
use iced::time::milliseconds;
use iced::widget::{Button, Container, Row, button, container, row, svg, text};
use iced::{
    Alignment, Background, Border, Color, Element, Length, Subscription, Task, padding, theme,
};
use iced_layershell::build_pattern::application;
use iced_layershell::reexport::{Anchor, Layer};
use iced_layershell::settings::LayerShellSettings;
use iced_layershell::to_layer_message;
use std::io;
use std::process::Stdio;
use std::sync::{Arc, Mutex};
use std::time::Instant;
use tokio::process::Command;

const UPDATE_WIFI_MS: u64 = 5000;

#[allow(unused)]
#[to_layer_message]
#[derive(Debug, Clone)]
enum Message {
    Tick(Instant),
    SetWorkspace(String, u32),
    OpenOverview,
    OpenPavucontrol,
    OpenImpala,
    SetDisplay(Display),
    NoOp,
}

#[derive(Debug, Clone)]
struct Monitor {
    ws_count: u32,
    current_ws: u8,
    id: String,
}

#[derive(Debug, Clone, Copy)]
enum WifiStrength {
    Excellent,
    Good,
    Medium,
    Bad,
    NoWifi,
}

#[derive(Debug, Clone)]
struct Network {
    ssid: String,
    strength: WifiStrength,
}

#[derive(Debug, Clone)]
struct Audio {
    volume: String,
    is_muted: bool,
}

impl Default for Network {
    fn default() -> Self {
        Self {
            ssid: "-".into(),
            strength: WifiStrength::Medium,
        }
    }
}

type SharedSocket = Arc<Mutex<niri_ipc::socket::Socket>>;

struct State {
    wifi_good_handle: svg::Handle,
    wifi_medium_handle: svg::Handle,
    wifi_bad_handle: svg::Handle,
    wifi_none_handle: svg::Handle,
    audio_handle: svg::Handle,
    no_audio_handle: svg::Handle,
    power_handle: svg::Handle,
    binoculars_handle: svg::Handle,
    clock_handle: svg::Handle,
    brightness_handle: svg::Handle,
    niri_socket: SharedSocket,
    display: Display,
}

#[derive(Debug, Clone)]
struct Display {
    audio: Audio,
    power_str: String,
    monitors: Vec<Monitor>,
    network: Network,
    date_time: DateTime<Local>,
    brightness: String,
    delta_ms: u64,
}

const SVG_SIZE: u32 = 16;

fn bg_color() -> Background {
    Background::Color(Color::from_rgb8(100, 100, 50))
}

fn main() -> iced_layershell::Result {
    application(State::init, State::namespace, State::update, State::view)
        .layer_settings(LayerShellSettings {
            anchor: Anchor::Bottom | Anchor::Left | Anchor::Right,
            layer: Layer::Top,
            exclusive_zone: 28,
            size: Some((1920, 32)),
            margin: (0, 10, 5, 10),
            ..Default::default()
        })
        .subscription(subscriptions)
        .style(State::app_style)
        .run()
}

fn subscriptions(_state: &State) -> Subscription<Message> {
    iced::time::every(milliseconds(64)).map(Message::Tick)
}

impl State {
    fn init() -> (Self, Task<Message>) {
        let wifi_good_handle = svg::Handle::from_path(format!(
            "{}/resources/wifi-good.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let wifi_medium_handle = svg::Handle::from_path(format!(
            "{}/resources/wifi-medium.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let wifi_bad_handle = svg::Handle::from_path(format!(
            "{}/resources/wifi-bad.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let wifi_none_handle = svg::Handle::from_path(format!(
            "{}/resources/wifi-none.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let audio_handle = svg::Handle::from_path(format!(
            "{}/resources/speaker.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let no_audio_handle = svg::Handle::from_path(format!(
            "{}/resources/no-audio.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let power_handle = svg::Handle::from_path(format!(
            "{}/resources/power.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let binoculars_handle = svg::Handle::from_path(format!(
            "{}/resources/binoculars.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let clock_handle = svg::Handle::from_path(format!(
            "{}/resources/clock.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let brightness_handle = svg::Handle::from_path(format!(
            "{}/resources/brightness.svg",
            env!("CARGO_MANIFEST_DIR")
        ));

        let display = Display {
            network: Network::default(),
            audio: Audio {
                volume: "-".into(),
                is_muted: false,
            },
            power_str: "-".into(),
            monitors: vec![],
            date_time: Local::now(),
            // Every 5 sec wifi is updated so start with 5 sec offset to immediately update
            delta_ms: UPDATE_WIFI_MS,
            brightness: "100%".into(),
        };

        let niri_socket = Arc::new(Mutex::new(
            niri_ipc::socket::Socket::connect().expect("failed to connect to niri socket"),
        ));

        let state = State {
            wifi_good_handle,
            wifi_medium_handle,
            wifi_bad_handle,
            wifi_none_handle,
            audio_handle,
            no_audio_handle,
            power_handle,
            binoculars_handle,
            clock_handle,
            brightness_handle,
            niri_socket,
            display,
        };

        (state, Task::none())
    }

    fn namespace() -> String {
        "Hail bar".to_string()
    }

    fn update(&mut self, message: Message) -> Task<Message> {
        let current_ms = self.display.delta_ms;
        let current_network = self.display.network.clone();
        let current_audio = self.display.audio.clone();

        match message {
            Message::Tick(instant) => {
                let socket = self.niri_socket.clone();

                Task::future(async move {
                    let elapsed_ms: u64 = instant.elapsed().as_millis() as u64;
                    let mut delta_ms = current_ms + elapsed_ms;

                    let network = if UPDATE_WIFI_MS < delta_ms {
                        delta_ms = 0;
                        get_network().await.unwrap_or(current_network)
                    } else {
                        current_network
                    };

                    let display = Display {
                        date_time: Local::now(),
                        audio: get_audio().await.unwrap_or(current_audio),
                        power_str: get_power_str().await.unwrap_or("? battery".into()),
                        monitors: get_monitors(&socket).unwrap_or_default(),
                        brightness: get_brightness().await.unwrap_or("? brightness".into()),
                        network,
                        delta_ms,
                    };

                    Message::SetDisplay(display)
                })
            }
            Message::SetWorkspace(monitor_id, ws_index) => {
                let socket = self.niri_socket.clone();

                Task::future(async move {
                    let _ = set_workspace(&socket, monitor_id, ws_index);
                    Message::NoOp
                })
            }
            Message::OpenOverview => {
                let socket = self.niri_socket.clone();

                Task::future(async move {
                    let _ = open_overview(&socket);
                    Message::NoOp
                })
            }
            Message::OpenPavucontrol => {
                let socket = self.niri_socket.clone();
                Task::future(async move {
                    let _ = spawn_app(&socket, vec!["pavucontrol".into()]);
                    Message::NoOp
                })
            }
            Message::OpenImpala => {
                let socket = self.niri_socket.clone();
                Task::future(async move {
                    let _ = spawn_app(
                        &socket,
                        vec![
                            "ghostty".into(),
                            "--title=impala".into(),
                            "--window-width=120".into(),
                            "--window-height=34".into(),
                            "-e".into(),
                            "impala".into(),
                        ],
                    );
                    Message::NoOp
                })
            }
            Message::SetDisplay(display) => {
                self.display = display;

                Task::none()
            }
            Message::NoOp => Task::none(),
            _ => panic!("Not implemented"),
        }
    }

    fn view(&self) -> Element<'_, Message> {
        container(
            row![
                outer(workspaces_view(self)).align_x(Alignment::Start),
                outer(time_date_view(self)).align_x(Alignment::Center),
                outer(info_view(self)).align_x(Alignment::End)
            ]
            .width(Length::Fill)
            .spacing(10),
        )
        .center_y(32)
        .padding(padding::left(5).right(5))
        .style(style_container)
        .into()
    }

    fn app_style(&self, _theme: &iced::Theme) -> theme::Style {
        theme::Style {
            background_color: Color::TRANSPARENT,
            text_color: Color::WHITE,
        }
    }
}

fn spawn_app(socket: &SharedSocket, command: Vec<String>) -> io::Result<()> {
    let mut s = socket.lock().unwrap();
    let _ = s.send(niri_ipc::Request::Action(niri_ipc::Action::Spawn { command }))?;
    Ok(())
}

fn open_overview(socket: &SharedSocket) -> io::Result<()> {
    let mut s = socket.lock().unwrap();

    let _ = s.send(niri_ipc::Request::Action(
        niri_ipc::Action::ToggleOverview {},
    ))?;

    Ok(())
}

fn set_workspace(socket: &SharedSocket, monitor_id: String, index: u32) -> io::Result<()> {
    let mut s = socket.lock().unwrap();

    let _ = s.send(niri_ipc::Request::Action(niri_ipc::Action::FocusMonitor {
        output: monitor_id,
    }))?;

    let _ = s.send(niri_ipc::Request::Action(
        niri_ipc::Action::FocusWorkspace {
            reference: niri_ipc::WorkspaceReferenceArg::Index(index as u8),
        },
    ))?;

    Ok(())
}

fn get_monitors(socket: &SharedSocket) -> io::Result<Vec<Monitor>> {
    let mut s = socket.lock().unwrap();

    let reply = s.send(niri_ipc::Request::Workspaces)?;

    let Ok(niri_ipc::Response::Workspaces(workspaces)) = reply else {
        return Err(io::Error::new(io::ErrorKind::Other, "unexpected response"));
    };

    let mut monitors: Vec<Monitor> = Vec::new();

    for ws in workspaces {
        let Some(output) = &ws.output else {
            continue;
        };

        let pos = if let Some(p) = monitors.iter().position(|m| &m.id == output) {
            p
        } else {
            monitors.push(Monitor {
                ws_count: 0,
                current_ws: 0,
                id: output.clone(),
            });
            monitors.len() - 1
        };

        monitors[pos].ws_count += 1;

        if ws.is_active {
            monitors[pos].current_ws = ws.idx;
        }
    }

    Ok(monitors)
}

async fn get_network() -> io::Result<Network> {
    let wifi = Command::new("iwctl")
        .args(["station", "wlan0", "show"])
        .stdout(Stdio::null())
        .output()
        .await?;

    let mut network = Network {
        ssid: "-".into(),
        strength: WifiStrength::Medium,
    };

    for line in String::from_utf8_lossy(&wifi.stdout).trim().lines() {
        if let Some(ssid) = line.split("Connected network").nth(1) {
            network.ssid = ssid.trim().to_string();
        } else if let Some(dbms) = line.split("AverageRSSI").nth(1) {
            network.strength = dbms
                .split_whitespace()
                .next()
                .map(|str| match str.trim().parse::<i32>().map(|i| i.abs()) {
                    Ok(n) if n <= 60 => WifiStrength::Excellent,
                    Ok(n) if n <= 70 => WifiStrength::Good,
                    Ok(n) if n <= 80 => WifiStrength::Medium,
                    _ => WifiStrength::Bad,
                })
                .unwrap_or(WifiStrength::Medium)
        } else if let Some("disconnected") = line.split("State").nth(1).map(|s| s.trim()) {
            network.strength = WifiStrength::NoWifi
        }
    }

    Ok(network)
}

async fn get_brightness() -> io::Result<String> {
    let brightness = Command::new("brightnessctl")
        .args(["--machine-readable"])
        .stdout(Stdio::piped())
        .output()
        .await?;

    if let Some(line) = String::from_utf8_lossy(&brightness.stdout)
        .trim()
        .lines()
        .next()
    {
        if let Some(brightness_percentage) = line.split(',').nth(3) {
            return Ok(brightness_percentage.to_string());
        }
    }

    Err(io::Error::new(
        std::io::ErrorKind::InvalidData,
        "No brightness data found".to_string(),
    ))
}

async fn get_audio() -> io::Result<Audio> {
    let pamixer = Command::new("pamixer")
        .arg("--get-volume")
        .stdout(Stdio::piped())
        .output()
        .await?;

    let display = String::from_utf8_lossy(&pamixer.stdout).trim().to_string();

    let pamixer = Command::new("pamixer")
        .arg("--get-mute")
        .stdout(Stdio::piped())
        .output()
        .await?;

    let is_muted = String::from_utf8_lossy(&pamixer.stdout).trim() == "true";

    Ok(Audio {
        volume: display,
        is_muted,
    })
}

async fn get_power_str() -> io::Result<String> {
    Ok(
        tokio::fs::read_to_string("/sys/class/power_supply/BAT1/capacity")
            .await?
            .trim()
            .to_string(),
    )
}

fn outer(elem: Element<'_, Message>) -> Container<'_, Message> {
    container(elem).width(Length::Fill)
}

fn workspaces_view(state: &State) -> Element<'_, Message> {
    let display = &state.display;
    let mut ws_containers = vec![];

    let overview_btn: Element<'_, Message> =
        button(svg(state.binoculars_handle.clone()).width(24).height(32))
            .style(|_, _| button::Style {
                background: Some(Color::from_rgb8(0, 167, 119).into()),
                border: Border {
                    color: Color::BLACK,
                    width: 2.,
                    radius: Radius::new(5),
                },
                ..Default::default()
            })
            .on_press(Message::OpenOverview)
            .into();

    ws_containers.push(overview_btn);

    for monitor in display.monitors.iter() {
        let button_style = |btn_ws_index: u32| -> button::Style {
            if monitor.current_ws as u32 == btn_ws_index {
                button::Style {
                    background: Some(Color::from_rgb8(0, 167, 119).into()),
                    border: Border {
                        color: Color::BLACK,
                        width: 2.,
                        radius: Radius::new(5),
                    },
                    ..Default::default()
                }
            } else {
                button::Style {
                    text_color: Color::from_rgb8(75, 75, 75),
                    background: Some(Color::from_rgb8(11, 11, 11).into()),
                    border: Border {
                        color: Color::BLACK,
                        width: 2.,
                        radius: Radius::new(5),
                    },
                    ..Default::default()
                }
            }
        };

        let mut buttons = vec![module(row![text(&monitor.id)]).into()];

        for i in 1..=monitor.ws_count {
            buttons.push(
                button(text(i.to_string()))
                    .on_press(Message::SetWorkspace(monitor.id.to_string(), i))
                    .style(move |_theme, _status| button_style(i))
                    .width(Length::Shrink)
                    .into(),
            );
        }

        let ws_container = container(
            Row::with_children(buttons)
                .align_y(Alignment::Center)
                .height(32)
                .spacing(2),
        )
        .align_x(Alignment::Start)
        .width(Length::Shrink)
        .into();

        ws_containers.push(ws_container);
    }

    Row::with_children(ws_containers)
        .align_y(Alignment::Center)
        .height(32)
        .spacing(20)
        .into()
}

fn time_date_view(state: &State) -> Element<'_, Message> {
    let formatted = format!("{}", state.display.date_time.format("%d/%m/%Y %H:%M"));

    fn module_style(_: &iced::Theme) -> container::Style {
        container::Style {
            background: Some(Color::from_rgb8(11, 11, 11).into()),
            border: Border {
                color: Color::BLACK,
                width: 2.,
                radius: Radius::new(5.),
            },
            ..Default::default()
        }
    }

    container(
        row![
            svg(state.clock_handle.clone())
                .style(|_, _| {
                    svg::Style {
                        color: Some(Color::from_rgb8(0, 167, 119)),
                    }
                })
                .width(SVG_SIZE)
                .height(32),
            text(formatted)
                .height(32)
                .align_y(Alignment::Center)
                .align_x(Alignment::Center)
        ]
        .spacing(10),
    )
    .align_x(Alignment::Center)
    .align_y(Alignment::Center)
    .width(Length::Shrink)
    .padding(padding::right(10).left(10))
    .style(module_style)
    .into()
}

fn info_view(state: &State) -> Element<'_, Message> {
    let display = &state.display;

    let (wifi_handle, color) = match display.network.strength {
        WifiStrength::Excellent => (
            state.wifi_good_handle.clone(),
            Color::from_rgb8(76, 175, 80),
        ),
        WifiStrength::Good => (
            state.wifi_good_handle.clone(),
            Color::from_rgb8(139, 195, 74),
        ),
        WifiStrength::Medium => (
            state.wifi_medium_handle.clone(),
            Color::from_rgb8(255, 193, 7),
        ),
        WifiStrength::Bad => (state.wifi_bad_handle.clone(), Color::from_rgb8(244, 67, 54)),
        WifiStrength::NoWifi => (
            state.wifi_none_handle.clone(),
            Color::from_rgb8(245, 73, 39),
        ),
    };

    container(
        row![
            module_button(row![
                svg(wifi_handle)
                    .style(move |_, _| { svg::Style { color: Some(color) } })
                    .width(SVG_SIZE)
                    .height(SVG_SIZE),
                text(&display.network.ssid)
            ])
            .on_press(Message::OpenImpala),
            module(row![
                svg(state.brightness_handle.clone())
                    .width(SVG_SIZE)
                    .height(SVG_SIZE),
                text(&display.brightness)
            ]),
            module_button(row![
                if display.audio.is_muted {
                    svg(state.no_audio_handle.clone())
                        .width(SVG_SIZE)
                        .height(SVG_SIZE)
                } else {
                    svg(state.audio_handle.clone())
                        .width(SVG_SIZE)
                        .height(SVG_SIZE)
                },
                text(&display.audio.volume)
            ])
            .on_press(Message::OpenPavucontrol),
            module(row![
                svg(state.power_handle.clone())
                    .width(SVG_SIZE)
                    .height(SVG_SIZE),
                text(&display.power_str)
            ]),
        ]
        .spacing(5),
    )
    .align_x(Alignment::End)
    .width(Length::Shrink)
    .padding(padding::right(10).left(10))
    .into()
}

fn module_button(row: iced::widget::Row<'_, Message>) -> Button<'_, Message> {
    button(
        row.spacing(10)
            .width(Length::Shrink)
            .align_y(Alignment::Center)
            .height(32),
    )
    .padding(padding::right(10).left(10))
    .style(button_module_style)
}

fn module(row: iced::widget::Row<'_, Message>) -> Container<'_, Message> {
    fn module_style(_: &iced::Theme) -> container::Style {
        container::Style {
            background: Some(bg_color()),
            border: Border {
                color: Color::BLACK,
                width: 2.,
                radius: Radius::new(5.),
            },
            ..Default::default()
        }
    }

    container(
        row.spacing(10)
            .width(Length::Shrink)
            .align_y(Alignment::Center)
            .height(32),
    )
    .align_x(Alignment::Center)
    .padding(padding::right(10).left(10))
    .style(module_style)
}

fn button_module_style(_: &iced::Theme, _: button::Status) -> button::Style {
    button::Style {
        text_color: Color::WHITE,
        background: Some(bg_color()),
        border: Border {
            color: Color::BLACK,
            width: 2.,
            radius: Radius::new(5.),
        },
        ..Default::default()
    }
}

fn style_container(_theme: &iced::Theme) -> container::Style {
    container::Style {
        background: Some(Background::Color(Color::TRANSPARENT)),
        border: Border::default().width(1),
        ..Default::default()
    }
}
