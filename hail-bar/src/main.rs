use chrono::{DateTime, Local};
use iced::border::Radius;
use iced::futures::io;
use iced::time::milliseconds;
use iced::widget::{button, container, row, svg, text, Button, Container, Row};
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

#[derive(Debug)]
struct State {
    wifi_handle: svg::Handle,
    audio_handle: svg::Handle,
    power_handle: svg::Handle,
    display: Display,
}

#[derive(Debug, Clone)]
struct Display {
    wifi_str: String,
    audio_str: String,
    power_str: String,
    workspaces: Workspaces,
    date_time: DateTime<Local>,
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
    let wifi_handle =
        svg::Handle::from_path(format!("{}/resources/wifi.svg", env!("CARGO_MANIFEST_DIR")));

    let audio_handle = svg::Handle::from_path(format!(
        "{}/resources/speaker.svg",
        env!("CARGO_MANIFEST_DIR")
    ));

    let power_handle = svg::Handle::from_path(format!(
        "{}/resources/power.svg",
        env!("CARGO_MANIFEST_DIR")
    ));

    let display = Display {
        wifi_str: "-".into(),
        audio_str: "-".into(),
        power_str: "-".into(),
        workspaces: Workspaces {
            count: 2,
            current: 1,
        },
        date_time: Local::now(),
        delta_ms: 1000,
    };

    let state = State {
        wifi_handle,
        audio_handle,
        power_handle,
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
    let current_wifi_str = state.display.wifi_str.clone();

    match message {
        Message::Tick(instant) => Task::future(async move {
            let elapsed_ms: u64 = instant.elapsed().as_millis().try_into().unwrap();

            let mut delta_ms = current_ms + elapsed_ms;

            let wifi_str = if 1000 < delta_ms {
                delta_ms -= 1000;
                get_wifi_str().await.unwrap_or("? WiFi".into())
            } else {
                current_wifi_str
            };

            let display = Display {
                date_time: Local::now(),
                audio_str: get_audio_str().await.unwrap_or("? audio".into()),
                power_str: get_power_str().await.unwrap_or("? battery".into()),
                workspaces: get_current_workspace(current_workspaces)
                    .await
                    .unwrap_or(current_workspaces),
                wifi_str,
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

async fn get_wifi_str() -> io::Result<String> {
    let mut wifi = Command::new("iwctl")
        .args(["station", "wlan0", "show"])
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .spawn()?;

    let wifi_out: Stdio = wifi
        .stdout
        .take()
        .unwrap()
        .try_into()
        .expect("failed to convert to Stdio");

    let rg = Command::new("rg")
        .args(["Connected network", "-r", "$1"])
        .stdin(wifi_out) // Pipe ls_output to grep's stdin
        .stdout(Stdio::piped())
        .spawn()?;

    let output = rg.wait_with_output().await?;

    Ok(String::from_utf8_lossy(&output.stdout).trim().to_string())
}

async fn get_audio_str() -> io::Result<String> {
    let pamixer = Command::new("pamixer")
        .arg("--get-volume")
        .stdout(Stdio::piped())
        .output()
        .await?;

    Ok(String::from_utf8_lossy(&pamixer.stdout).trim().to_string())
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
    let binoculars_handle = svg::Handle::from_path(format!(
        "{}/resources/binoculars.svg",
        env!("CARGO_MANIFEST_DIR")
    ));

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
        button(svg(binoculars_handle).width(24).height(32))
            .style(|_, _| button::Style {
                background: Some(Color::from_rgb8(0, 167, 119).into()),
                border: Border {
                    color: Color::BLACK,
                    width: 2.,
                    radius: Radius::new(5),
                },
                ..Default::default()
            })
            .on_press(Message::OpenOverview).into()
    ];

    for i in 1..=state.display.workspaces.count {
        buttons.push(
            button(text(i.to_string()))
                .on_press(Message::SetWorkspace(i))
                .style(move |_theme, _status| button_style(i))
                .width(Length::Shrink)
                .into()
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

    container(row![
        text(formatted)
            .align_y(Alignment::Center)
            .height(32)
            .align_x(Alignment::Center)
    ])
    .align_x(Alignment::Center)
    .width(Length::Shrink)
    .padding(padding::right(10).left(10))
    .style(module_style)
    .into()
}

fn info(state: &State) -> Element<'_, Message> {
    let display = &state.display;

    container(
        row![
            module(row![
                svg(state.wifi_handle.clone())
                    .width(SVG_SIZE)
                    .height(SVG_SIZE),
                text(&display.wifi_str)
            ]),
            module_button(row![
                svg(state.audio_handle.clone())
                    .width(SVG_SIZE)
                    .height(SVG_SIZE),
                text(&display.audio_str)
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

fn style_container(_theme: &iced::Theme) -> container::Style {
    container::Style {
        background: Some(Background::Color(Color::TRANSPARENT)),
        border: Border::default().width(1),
        ..Default::default()
    }
}
