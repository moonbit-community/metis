import "./index.css";
import { Composition } from "remotion";
import { MetisOverview } from "./Composition";

export const RemotionRoot = () => {
  return (
    <Composition
      id="MetisOverview"
      component={MetisOverview}
      durationInFrames={450}
      fps={30}
      width={1920}
      height={1080}
    />
  );
};
