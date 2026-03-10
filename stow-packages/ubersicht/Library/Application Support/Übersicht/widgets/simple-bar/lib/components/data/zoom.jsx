import * as Uebersicht from "uebersicht";
import * as DataWidget from "./data-widget.jsx";
import * as DataWidgetLoader from "./data-widget-loader.jsx";
import * as Icons from "../icons.jsx";
import useWidgetRefresh from "../../hooks/use-widget-refresh";
import * as Settings from "../../settings";
import * as Utils from "../../utils";

export { zoomStyles as styles } from "../../styles/components/data/zoom";

const settings = Settings.get();
const { widgets, zoomWidgetOptions } = settings;
const { zoomWidget } = widgets;
const { refreshFrequency, showVideo, showMic } = zoomWidgetOptions;

const DEFAULT_REFRESH_FREQUENCY = 5000;
const REFRESH_FREQUENCY = Settings.getRefreshFrequency(
	refreshFrequency,
	DEFAULT_REFRESH_FREQUENCY
);

export const Widget = () => {
	const [state, setState] = Uebersicht.React.useState();
	const [loading, setLoading] = Uebersicht.React.useState(zoomWidget);

	const getZoom = async () => {
		const [mic, video] = await Promise.all([
			Uebersicht.run(
				`osascript ./simple-bar/lib/scripts/zoom-mute-status.applescript`
			),
			Uebersicht.run(
				`osascript ./simple-bar/lib/scripts/zoom-video-status.applescript`
			),
		]);
		setState({
			mic: Utils.cleanupOutput(mic),
			video: Utils.cleanupOutput(video),
		});
		setLoading(false);
	};

	useWidgetRefresh(zoomWidget, getZoom, REFRESH_FREQUENCY);

	if (loading) return <DataWidgetLoader.Widget className="zoom" />;
	if (!state || (!state.mic.length && !state.video.length)) return null;

	const { mic, video, toggle } = state;
	const VideoIcon = video === "off" ? Icons.CameraOff : Icons.Camera;
	const MicIcon = mic === "off" ? Icons.MicOff : Icons.MicOn;

	const toggleVideo = async () => {
		setState({ video: video === "off" ? "on" : "off" });
		await Uebersicht.run(
			`osascript -e 'tell app "System Events" to keystroke "V" using {shift down, command down}'`
		);
	}
	const toggleMic = async () => {
		setState({ mic: mic === "off" ? "on" : "off" });
		await Uebersicht.run(
			`osascript -e 'tell app "System Events" to keystroke "A" using {shift down, command down}'`
		);
	}

	return (
		<DataWidget.Widget classes="zoom">
			{showVideo && <VideoIcon onClick={toggleVideo} className={`zoom__icon zoom__icon--${video}`} />}
			{showMic && <MicIcon onClick={toggleMic} className={`zoom__icon zoom__icon--${mic}`} />}
		</DataWidget.Widget>
	);
};
