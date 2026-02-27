// Update every second for the clock. Expensive elements should
// throttle themselves
export const refreshFrequency = 5000; // ms

const theme = {
  borderSize: 0,
  thickness: "2px",
  connectedColor: "lime",
  connectedSize: "20px",
  green: "#97c475",
  green_threshold: 80,
  yellow: "#e5c07b",
  yellow_threshold: 55,
  orange: "#d09a6a",
  orange_threshold: 30,
  red: "#e06c75",
  screenSize: window.innerWidth,
};

const computeUsedBattery = (usedPercentage) => {
  const paddingPercent = (100 - usedPercentage) / 2;
  return theme.screenSize * (paddingPercent / 100);
};
const computeBatteryColor = (level) => {
  const {
    green,
    green_threshold,
    yellow,
    yellow_threshold,
    orange,
    orange_threshold,
    red,
  } = theme;

  if (level > green_threshold) return green;
  if (level > yellow_threshold) return yellow;
  if (level > orange_threshold) return orange;
  return red;
};

const getBaseBarStyle = () => {
  const height = theme.thickness;

  return {
    bottom: 0,
    position: "fixed",
    overflow: "hidden",
    height,
  };
};

const getBatteryBarStyle = (batteryPercentage) => {
  const background = computeBatteryColor(batteryPercentage);
  const borderSize = theme.borderSize + computeUsedBattery(batteryPercentage);

  return {
    ...getBaseBarStyle(),
    right: borderSize,
    left: borderSize,
    background,
  };
};

const getChargingAnimationStyle = (isCharging) => {
  if (isCharging) {
    return {
      animationName: "color",
      animationDuration: "1s",
      animationIterationCount: "infinite",
      animationDirection: "alternate-reverse",
      animationTimingFunction: "ease",
    };
  } else {
    return {};
  }
};

const getChargingBarStyle = (isCharging) => {
  return {
    ...getBaseBarStyle(),
    ...getChargingAnimationStyle(isCharging),
    background: theme.connectedColor,
    width: theme.connectedSize,
  };
};

const getLeftChargingBarStyle = (isCharging) => {
  return {
    ...getChargingBarStyle(isCharging),
    left: 0,
    marginLeft: 0,
    marginRight: "auto",
  };
};

const getRightChargingBarStyle = (isCharging) => {
  return {
    ...getChargingBarStyle(isCharging),
    right: 0,
    marginLeft: "auto",
    marginRight: 0,
  };
};

export const command = `echo "{
	\\\"batteryPercentage\\\": $(system_profiler SPPowerDataType | grep 'State of Charge' | awk '{ print $5 }'),
	\\\"connectedStatus\\\": \\\"$(system_profiler SPPowerDataType | grep 'Connected' | head -n1 | awk '{$1=$1};1')\\\",
	\\\"chargingStatus\\\": \\\"$(system_profiler SPPowerDataType | grep 'Charging' | head -n1 | awk '{$1=$1};1')\\\"
}"`;

export const className = `
	@keyframes color {
		to {
			background-color: ${theme.green};
		}
	}
`;

export const render = ({ output, error }) => {
  const { batteryPercentage, connectedStatus, chargingStatus } =
    JSON.parse(output);
  const isConnected = connectedStatus == "Connected: Yes";
  const isCharging = chargingStatus == "Charging: Yes";

  if (error) {
    console.log(new Date());
    console.log(error);
    console.log(String(error));
  }

  const batteryBarStyle = getBatteryBarStyle(batteryPercentage);
  const leftChargingBarStyle = getLeftChargingBarStyle(isCharging);
  const rightChargingBarStyle = getRightChargingBarStyle(isCharging);

  return (
    <div>
      <div style={batteryBarStyle} />
      {isConnected && <div style={leftChargingBarStyle} />}
      {isConnected && <div style={rightChargingBarStyle} />}
    </div>
  );
};
