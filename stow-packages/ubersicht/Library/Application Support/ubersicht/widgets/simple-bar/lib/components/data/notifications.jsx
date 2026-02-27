import * as Uebersicht from "uebersicht";
import * as DataWidget from "./data-widget.jsx";
import * as DataWidgetLoader from "./data-widget-loader.jsx";
import * as Icons from "../icons.jsx";
import useWidgetRefresh from "../../hooks/use-widget-refresh";
import * as Settings from "../../settings";
import * as Utils from "../../utils";
import * as AppIdentifiers from "../../app-identifiers";
import * as AppOptions from "../../app-options";
import * as AppNotifications from "../../app-notifications";

export { notificationsStyle as styles } from "../../styles/components/data/notifications.js";

const settings = Settings.get();
const { widgets, notificationWidgetOptions } = settings;
const { notificationWidget } = widgets;
const { refreshFrequency } = notificationWidgetOptions;

const DEFAULT_REFRESH_FREQUENCY = 1000;
const REFRESH_FREQUENCY = Settings.getRefreshFrequency(
  refreshFrequency,
  DEFAULT_REFRESH_FREQUENCY
);

let database;
async function getDatabase() {
  return (
    await Uebersicht.run(
      `lsof -p "$(ps aux | grep -m1 usernoted | awk '{ print $2 }')" | awk '{ print $NF }' | grep 'db2/db$'`
    )
  ).trim();
}

const openApp = (bundleIdentifier) =>
  Uebersicht.run(`open -b ${bundleIdentifier}`);

export const Widget = () => {
  const [state, setState] = Uebersicht.React.useState({});
  const [loading, setLoading] = Uebersicht.React.useState(notificationWidget);

  const getNotifications = async () => {
    // Sometimes, when trying to get the database, the command doesn't return anything,
    //   so once we get it successfully once, we should keep the value.
    if (!database) database = await getDatabase();

    // handle default execution
    const defaultList = Object.keys(AppNotifications.methods.default)
      .filter((appName) => notificationWidgetOptions[AppOptions.apps[appName]])
      .map((appName) => AppIdentifiers.apps[appName]);

    const defaultAppBadgeJsonList = await Uebersicht.run(
      `./simple-bar/lib/scripts/notifications-default.sh "${database}" "${defaultList.join(
        "', '"
      )}"`
    )
			.then((output) => JSON.parse(output))
			.catch(defaultList.map((key) => ({ identifier: key, count: 0 })));

    const getAppNameByIdentifier = (object, value) => {
      return Object.keys(object).find((key) => object[key] === value);
    }

    defaultAppBadgeJsonList.forEach((appObject) => {
      const appName = getAppNameByIdentifier(
        AppIdentifiers.apps,
        appObject.identifier
      );
      setState((state) => ({ ...state, [appName]: appObject.badge }));
    });

    // handle python execution
    const pythonAppBadgeJsonList = await Uebersicht.run(
      `./simple-bar/lib/scripts/notifications-other.py3`
    )
			.then((output) => JSON.parse(output.replace(/'/g, '"').replace(/<null>/g, "0")))
			.catch({});

    Object.keys(AppNotifications.methods.python)
      .filter((appName) => notificationWidgetOptions[AppOptions.apps[appName]])
      .forEach((appName) =>
        setState((state) => ({
          ...state,
          [appName]: pythonAppBadgeJsonList[appName],
        }))
      );

    setLoading(false);
  };

  useWidgetRefresh(notificationWidget, getNotifications, REFRESH_FREQUENCY);

  if (loading) return <DataWidgetLoader.Widget className="notification" />;
  if (!state) return null;

  const onClick = (bundleIdentifier) => (e) => {
    Utils.clickEffect(e);
    openApp(bundleIdentifier);
  };

  return (
    <DataWidget.Widget classes="notifications">
      {Object.keys(state)
        .filter(
          (appName) =>
            state[appName] &&
            notificationWidgetOptions[AppOptions.apps[appName]]
        )
        .map((appName, _) => {
          const Icon = Icons[appName.replace(/ /, "")] || Icons.Default;
          return (
            <div
              onClick={onClick(AppIdentifiers.apps[appName])}
              className="notification"
            >
              <Icon />
              {state[appName]}
            </div>
          );
        })}
    </DataWidget.Widget>
  );
};
