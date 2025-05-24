/// <reference types="vite-plugin-svgr/client" />

declare module "*.svg" {
  const src: string;
  export default src;
}

declare module "*.module.scss" {
  const classes: { [key: string]: string };
  export default classes;
}
