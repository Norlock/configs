use chrono::{DateTime, Local};
use core::num;
use core::option::Option::Some;
use iced::border::Radius;
use iced::futures::io;
use iced::time::milliseconds;
use iced::widget::{Button, Container, Row, button, container, row, svg, text};
use iced::{
    Alignment, Background, Border, Color, Element, Length, Subscription, Task, padding, theme,
};
use iced_layershell::build_pattern::application;
use iced_layershell::reexport::{Anchor, Layer};
use iced_layershell::settings::LayerShellSettings;
use iced_layershell::to_layer_message;
use std::process::Stdio;
use std::time::Instant;
use tokio::process::Command;

const UPDATE_WIFI_MS: u64 = 5000;

#[allow(unused)]
#[to_layer_message]
#[derive(Debug, Clone)]
enum Message {
    Tick(Instant),
    SetWorkspace(u32),
    OpenOverview,
    OpenPavucontrol,
    SetDisplay(Display),
    NoOp,
}

#[derive(Debug, Clone, Copy)]
struct Workspaces {
    count: u32,
    current: u32,
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

#[derive(Debug)]
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
    display: Display,
}

#[derive(Debug, Clone)]
struct Display {
    audio: Audio,
    power_str: String,
    workspaces: Workspaces,
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
    application(init, namespace, update, view)
        .layer_settings(LayerShellSettings {
            size: Some((1920, 32)),
            anchor: Anchor::Bottom | Anchor::Left | Anchor::Right,
            margin: (0, 10, 5, 10),
            layer: Layer::Top,
            exclusive_zone: 28,
            ..Default::default()
        })
        .subscription(subscriptions)
        .style(app_style)
        .run()
}

fn subscriptions(_state: &State) -> Subscription<Message> {
    iced::time::every(milliseconds(64)).map(Message::Tick)
}

fn namespace() -> String {
    "Hail bar".to_string()
}

fn init() -> (State, Task<Message>) {
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
        workspaces: Workspaces {
            count: 1,
            current: 1,
        },
        date_time: Local::now(),
        // Every 5 sec wifi is updated so start with 5 sec offset to immediately update
        delta_ms: UPDATE_WIFI_MS,
        brightness: "100%".into(),
    };

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
        display,
    };

    (state, Task::none())
}

fn app_style(_state: &State, _theme: &iced::Theme) -> theme::Style {
    theme::Style {
        background_color: Color::TRANSPARENT,
        text_color: Color::WHITE,
    }
}

fn update(state: &mut State, message: Message) -> Task<Message> {
    let current_ms = state.display.delta_ms;
    let current_workspaces = state.display.workspaces;
    let current_network = state.display.network.clone();
    let current_audio = state.display.audio.clone();
    let current_brightness = state.display.brightness.clone();

    match message {
        Message::Tick(instant) => Task::future(async move {
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
                workspaces: get_current_workspace(current_workspaces)
                    .await
                    .unwrap_or(current_workspaces),
                brightness: get_brightness().await.unwrap_or(current_brightness),
                network,
                delta_ms,
            };

            Message::SetDisplay(display)
        }),
        Message::SetWorkspace(index) => Task::future(async move {
            let _ = set_workspace(index).await;
            Message::NoOp
        }),
        Message::OpenOverview => Task::future(async {
            let _ = open_overview().await;
            Message::NoOp
        }),
        Message::OpenPavucontrol => Task::future(async {
            let _ = open_pavucontrol().await;
            Message::NoOp
        }),
        Message::SetDisplay(display) => {
            state.display = display;

            Task::none()
        }
        Message::NoOp => Task::none(),
        _ => panic!("Not implemented"),
    }
}

async fn open_pavucontrol() -> tokio::io::Result<()> {
    Command::new("pavucontrol")
        .stdout(Stdio::inherit())
        .output()
        .await?;

    Ok(())
}

async fn open_overview() -> tokio::io::Result<()> {
    Command::new("niri")
        .args(["msg", "action", "toggle-overview"])
        .stdout(Stdio::piped())
        .output()
        .await?;

    Ok(())
}

async fn set_workspace(index: u32) -> tokio::io::Result<()> {
    Command::new("niri")
        .args(["msg", "action", "focus-workspace", &index.to_string()])
        .stdout(Stdio::piped())
        .output()
        .await?;

    Ok(())
}

async fn get_current_workspace(current_workspaces: Workspaces) -> tokio::io::Result<Workspaces> {
    let niri = Command::new("niri")
        .args(["msg", "workspaces"])
        .stdout(Stdio::piped())
        .output()
        .await?;

    let mut workspaces = Workspaces {
        current: current_workspaces.current,
        count: 0,
    };

    for (i, line) in String::from_utf8_lossy(&niri.stdout).lines().enumerate() {
        if i == 0 {
            continue;
        }

        workspaces.count += 1;

        if line.contains("*") {
            workspaces.current = line
                .split_whitespace()
                .last()
                .and_then(|word| word.trim().parse().ok())
                .unwrap_or(1);
        }
    }

    Ok(workspaces)
}

async fn get_network() -> io::Result<Network> {
    let wifi = Command::new("iwctl")
        .args(["station", "wlan0", "show"])
        .stdout(Stdio::piped())
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

fn view(state: &State) -> Element<'_, Message> {
    container(
        row![
            outer(workspaces(state)).align_x(Alignment::Start),
            outer(time_date(state)).align_x(Alignment::Center),
            outer(info(state)).align_x(Alignment::End)
        ]
        .width(Length::Fill)
        .spacing(10),
    )
    .center_y(32)
    .padding(padding::left(5).right(5))
    .style(style_container)
    .into()
}

fn outer(elem: Element<'_, Message>) -> Container<'_, Message> {
    container(elem).width(Length::Fill)
}

fn workspaces(state: &State) -> Element<'_, Message> {
    let display = &state.display;

    let button_style = |btn_ws_index: u32| -> button::Style {
        if display.workspaces.current == btn_ws_index {
            button::Style {
                background: Some(Color::from_rgb8(0, 167, 119).into()),
                border: Border {
                    color: Color::BLACK,
                    width: 2.,
                    radius: Radius::new(2.),
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

    let mut buttons: Vec<Element<'_, Message>> = vec![
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
            .into(),
    ];

    for i in 1..=state.display.workspaces.count {
        buttons.push(
            button(text(i.to_string()))
                .on_press(Message::SetWorkspace(i))
                .style(move |_theme, _status| button_style(i))
                .width(Length::Shrink)
                .into(),
        );
    }

    container(
        Row::with_children(buttons)
            .align_y(Alignment::Center)
            .height(32)
            .spacing(5),
    )
    .align_x(Alignment::Start)
    .width(Length::Fill)
    .into()
}

fn time_date(state: &State) -> Element<'_, Message> {
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

fn info(state: &State) -> Element<'_, Message> {
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
            module(row![
                svg(wifi_handle)
                    .style(move |_, _| { svg::Style { color: Some(color) } })
                    .width(SVG_SIZE)
                    .height(SVG_SIZE),
                text(&display.network.ssid)
            ]),
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
