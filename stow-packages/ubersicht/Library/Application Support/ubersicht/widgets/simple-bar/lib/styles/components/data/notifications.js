export const notificationsStyle = /* css */ `
.notifications {
  position: relative;
  display: flex;
  align-items: center;
  background-color: var(--foreground);
}
.simple-bar--background-color-as-foreground .notifications {
  color: var(--foreground);
  background-color: transparent;
}
.simple-bar--no-color-in-data .notifications {
  background-color: var(--foreground);
}
.notification svg {
  width: 14px;
  height: 14px;
  fill: var(--foreground);
  margin: 0 1px 0 4px;
  transform: translateZ(0);
}
.notification:hover {
  color: var(--blue);
}
.notification:hover svg {
  fill: var(--blue);
}
`;
