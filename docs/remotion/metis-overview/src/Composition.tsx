import type { CSSProperties, ReactNode } from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

const ink = "#172328";
const muted = "#667277";
const paper = "#f4f7f2";
const surface = "#fffdf7";
const line = "#d5ddcf";
const blue = "#2878d7";
const green = "#24955b";
const coral = "#ef604b";
const gold = "#c99020";
const dark = "#172328";

const graphNodes = [
  { id: 0, x: 300, y: 144, part: 0 },
  { id: 1, x: 158, y: 330, part: 0 },
  { id: 2, x: 432, y: 352, part: 0 },
  { id: 3, x: 668, y: 352, part: 1 },
  { id: 4, x: 942, y: 330, part: 1 },
  { id: 5, x: 800, y: 144, part: 1 },
];

const graphEdges = [
  [0, 1],
  [0, 2],
  [1, 2],
  [2, 3],
  [3, 4],
  [3, 5],
  [4, 5],
];

const compactCode = [
  "let graph = CsrGraph::new(...)",
  "let result =",
  "  part_graph_kway(graph, 2)",
  "result.part  // [0,0,0,1,1,1]",
];

const capabilityItems = [
  ["Graph partitioning", "part_graph_kway", blue],
  ["Mesh conversion", "mesh_to_dual / nodal", green],
  ["Fill-reducing order", "node_nd", gold],
  ["Safe boundary", "validated inputs + freed METIS arrays", coral],
] as const;

const partArray = [0, 0, 0, 1, 1, 1];

const fade = (frame: number, start: number, end: number) =>
  interpolate(frame, [start, end], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

const fadeOut = (frame: number, start: number, end: number) =>
  interpolate(frame, [start, end], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.16, 1, 0.3, 1),
  });

const move = (
  frame: number,
  input: [number, number],
  output: [number, number],
) =>
  interpolate(frame, input, output, {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
    easing: Easing.bezier(0.22, 1, 0.36, 1),
  });

const panelStyle: CSSProperties = {
  backgroundColor: surface,
  border: `2px solid ${line}`,
  borderRadius: 8,
  boxShadow: "0 18px 46px rgba(23, 35, 40, 0.09)",
};

const Header = ({ frame }: { frame: number }) => (
  <div
    style={{
      position: "absolute",
      left: 88,
      right: 88,
      top: 56,
      display: "flex",
      alignItems: "flex-start",
      justifyContent: "space-between",
    }}
  >
    <div>
      <div
        style={{
          color: ink,
          fontSize: 72,
          fontWeight: 880,
          lineHeight: 0.94,
          letterSpacing: 0,
          opacity: fade(frame, 0, 26),
          transform: `translateY(${move(frame, [0, 26], [28, 0])}px)`,
        }}
      >
        METIS from MoonBit
      </div>
      <div
        style={{
          marginTop: 18,
          color: muted,
          fontSize: 30,
          fontWeight: 670,
          lineHeight: 1.2,
          letterSpacing: 0,
          opacity: fade(frame, 14, 44),
          transform: `translateY(${move(frame, [14, 44], [18, 0])}px)`,
        }}
      >
        Build a graph, call the native partitioner, use the partition map.
      </div>
    </div>
    <div
      style={{
        ...panelStyle,
        padding: "18px 24px",
        color: dark,
        fontSize: 24,
        fontWeight: 820,
        opacity: fade(frame, 30, 58),
      }}
    >
      15 second walkthrough
    </div>
  </div>
);

const StoryBand = ({ frame }: { frame: number }) => {
  const entries = [
    {
      start: 0,
      end: 96,
      title: "Problem",
      text: "Split a graph into two balanced parts while cutting as few edges as possible.",
      color: coral,
    },
    {
      start: 78,
      end: 178,
      title: "MoonBit API",
      text: "Create a validated CSR graph, then call part_graph_kway(graph, 2).",
      color: blue,
    },
    {
      start: 160,
      end: 292,
      title: "METIS",
      text: "The native engine finds a low edge cut; here the bridge is the only crossing edge.",
      color: green,
    },
    {
      start: 274,
      end: 392,
      title: "Result",
      text: "part[i] tells which partition vertex i belongs to.",
      color: gold,
    },
    {
      start: 380,
      end: 450,
      title: "Binding surface",
      text: "The same package also wraps mesh conversion, ordering, and separators.",
      color: ink,
    },
  ];

  return (
    <div
      style={{
        position: "absolute",
        left: 88,
        right: 88,
        bottom: 66,
        height: 108,
      }}
    >
      {entries.map((entry) => {
        const visible =
          fade(frame, entry.start, entry.start + 20) *
          fadeOut(frame, entry.end - 20, entry.end);
        return (
          <div
            key={entry.title}
            style={{
              ...panelStyle,
              position: "absolute",
              inset: 0,
              opacity: visible,
              transform: `translateY(${(1 - visible) * 22}px)`,
              display: "flex",
              alignItems: "center",
              gap: 26,
              padding: "0 34px",
            }}
          >
            <div
              style={{
                width: 16,
                alignSelf: "stretch",
                backgroundColor: entry.color,
                borderRadius: 8,
              }}
            />
            <div
              style={{
                width: 210,
                color: entry.color,
                fontSize: 28,
                fontWeight: 860,
                letterSpacing: 0,
              }}
            >
              {entry.title}
            </div>
            <div
              style={{
                color: ink,
                fontSize: 34,
                fontWeight: 750,
                lineHeight: 1.18,
                letterSpacing: 0,
              }}
            >
              {entry.text}
            </div>
          </div>
        );
      })}
    </div>
  );
};

const CodeCard = ({ frame }: { frame: number }) => {
  const visible = fade(frame, 82, 116) * fadeOut(frame, 362, 392);
  const activeLine = frame < 156 ? 0 : frame < 230 ? 2 : frame < 362 ? 3 : -1;

  return (
    <div
      style={{
        ...panelStyle,
        position: "absolute",
        left: 88,
        top: 280,
        width: 448,
        height: 326,
        padding: 24,
        opacity: visible,
        transform: `translateX(${move(frame, [82, 116], [-44, 0])}px)`,
      }}
    >
      <div
        style={{
          color: blue,
          fontSize: 22,
          fontWeight: 850,
          letterSpacing: 0,
          marginBottom: 18,
        }}
      >
        Complete MoonBit example
      </div>
      <div
        style={{
          backgroundColor: dark,
          borderRadius: 8,
          padding: "20px 22px",
          fontFamily: "Menlo, Consolas, monospace",
          fontSize: 19,
          lineHeight: 1.7,
          letterSpacing: 0,
        }}
      >
        {compactCode.map((lineText, index) => (
          <div
            key={lineText}
            style={{
              color: index === activeLine ? "#ffe08a" : "#d9e6e1",
              fontWeight: index === activeLine ? 800 : 600,
              whiteSpace: "pre",
            }}
          >
            {lineText}
          </div>
        ))}
      </div>
      <div
        style={{
          marginTop: 18,
          display: "flex",
          gap: 10,
          color: muted,
          fontSize: 17,
          fontWeight: 730,
        }}
      >
        <Pill>xadj</Pill>
        <Pill>adjncy</Pill>
        <Pill>zero-based vertices</Pill>
      </div>
    </div>
  );
};

const Pill = ({ children }: { children: ReactNode }) => (
  <div
    style={{
      border: `2px solid ${line}`,
      borderRadius: 999,
      padding: "8px 12px",
      backgroundColor: "#f7fbf8",
      color: muted,
    }}
  >
    {children}
  </div>
);

const MetisCall = ({ frame }: { frame: number }) => {
  const visible = fade(frame, 150, 184) * fadeOut(frame, 304, 334);
  const pulse = 1 + Math.sin(frame / 7) * 0.025 * visible;

  return (
    <div
      style={{
        position: "absolute",
        left: 676,
        top: 770,
        width: 568,
        height: 92,
        borderRadius: 8,
        backgroundColor: dark,
        border: `3px solid ${coral}`,
        color: "#fff6df",
        opacity: visible,
        transform: `scale(${pulse})`,
        display: "flex",
        alignItems: "center",
        justifyContent: "space-between",
        padding: "0 34px",
        boxShadow: "0 20px 48px rgba(23, 35, 40, 0.16)",
      }}
    >
      <div style={{ fontSize: 28, fontWeight: 860, letterSpacing: 0 }}>
        part_graph_kway
      </div>
      <div
        style={{
          color: "#ffd47b",
          fontSize: 24,
          fontWeight: 820,
          letterSpacing: 0,
        }}
      >
        native METIS
      </div>
    </div>
  );
};

const GraphScene = ({ frame }: { frame: number }) => {
  const graphIn = fade(frame, 24, 70);
  const clusterHints = fade(frame, 28, 76) * fadeOut(frame, 156, 190);
  const partition = fade(frame, 208, 284);
  const bridgeCut = fade(frame, 238, 302);
  const resultFocus = fade(frame, 288, 342);
  const finalLift = move(frame, [380, 428], [0, -88]);
  const codePressure = fade(frame, 82, 116) * fadeOut(frame, 362, 392);
  const resultPressure = fade(frame, 288, 330) * fadeOut(frame, 396, 422);
  const graphLeft = 454 + codePressure * 126 - resultPressure * 58;
  const graphWidth = 1012 - codePressure * 126 - resultPressure * 104;

  return (
    <div
      style={{
        position: "absolute",
        left: graphLeft,
        top: 188 + finalLift,
        width: graphWidth,
        height: 570,
        opacity: graphIn,
      }}
    >
      <svg
        viewBox="0 0 1100 620"
        width="100%"
        height="100%"
        style={{ overflow: "visible" }}
      >
        <rect
          x="30"
          y="35"
          width="470"
          height="465"
          rx="12"
          fill="#e4f3ea"
          opacity={clusterHints * 0.9 + partition * 0.7}
        />
        <rect
          x="600"
          y="35"
          width="470"
          height="465"
          rx="12"
          fill="#e6effb"
          opacity={clusterHints * 0.9 + partition * 0.7}
        />
        <text
          x="182"
          y="540"
          fill={green}
          fontSize="30"
          fontWeight="850"
          opacity={partition}
        >
          part 0
        </text>
        <text
          x="760"
          y="540"
          fill={blue}
          fontSize="30"
          fontWeight="850"
          opacity={partition}
        >
          part 1
        </text>
        <text
          x="128"
          y="84"
          fill={green}
          fontSize="27"
          fontWeight="800"
          opacity={clusterHints}
        >
          dense group
        </text>
        <text
          x="718"
          y="84"
          fill={blue}
          fontSize="27"
          fontWeight="800"
          opacity={clusterHints}
        >
          dense group
        </text>
        {graphEdges.map(([from, to]) => {
          const a = graphNodes[from];
          const b = graphNodes[to];
          const bridge = from === 2 && to === 3;
          if (bridge && bridgeCut > 0.04) {
            return (
              <g key={`${from}-${to}`}>
                <line
                  x1={a.x}
                  y1={a.y}
                  x2={a.x + 76}
                  y2={a.y}
                  stroke={coral}
                  strokeWidth="12"
                  strokeLinecap="round"
                />
                <line
                  x1={b.x - 76}
                  y1={b.y}
                  x2={b.x}
                  y2={b.y}
                  stroke={coral}
                  strokeWidth="12"
                  strokeLinecap="round"
                />
                <text
                  x="488"
                  y="318"
                  fill={coral}
                  fontSize="76"
                  fontWeight="900"
                  opacity={bridgeCut}
                >
                  /
                </text>
                <text
                  x="420"
                  y="430"
                  fill={coral}
                  fontSize="30"
                  fontWeight="850"
                  opacity={bridgeCut}
                >
                  1 crossing edge
                </text>
              </g>
            );
          }
          return (
            <line
              key={`${from}-${to}`}
              x1={a.x}
              y1={a.y}
              x2={b.x}
              y2={b.y}
              stroke={bridge ? coral : "#7c8b8c"}
              strokeWidth={bridge ? 11 : 8}
              strokeLinecap="round"
              opacity={bridge ? 0.62 + partition * 0.34 : 0.78}
            />
          );
        })}
        {graphNodes.map((node) => {
          const fill = node.part === 0 ? green : blue;
          const scale = 1 + partition * 0.12 + resultFocus * 0.02;
          return (
            <g
              key={node.id}
              transform={`translate(${node.x} ${node.y}) scale(${scale})`}
            >
              <circle
                r="56"
                fill={partition > 0.04 ? fill : surface}
                stroke={partition > 0.04 ? "#ffffff" : ink}
                strokeWidth="7"
              />
              <text
                textAnchor="middle"
                dominantBaseline="central"
                fill={partition > 0.04 ? "#ffffff" : ink}
                fontSize="46"
                fontWeight="900"
              >
                {node.id}
              </text>
            </g>
          );
        })}
      </svg>
    </div>
  );
};

const ResultMap = ({ frame }: { frame: number }) => {
  const visible = fade(frame, 288, 330) * fadeOut(frame, 396, 422);

  return (
    <div
      style={{
        ...panelStyle,
        position: "absolute",
        right: 88,
        top: 266,
        width: 446,
        height: 410,
        padding: 28,
        opacity: visible,
        transform: `translateX(${move(frame, [288, 330], [46, 0])}px)`,
      }}
    >
      <div
        style={{
          color: gold,
          fontSize: 22,
          fontWeight: 860,
          letterSpacing: 0,
          marginBottom: 18,
        }}
      >
        Result map
      </div>
      <div
        style={{
          color: ink,
          fontSize: 29,
          fontWeight: 790,
          lineHeight: 1.2,
          marginBottom: 24,
        }}
      >
        part[i] is the partition for vertex i
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(6, 1fr)" }}>
        {partArray.map((part, index) => (
          <div key={`${index}-${part}`} style={{ textAlign: "center" }}>
            <div
              style={{
                color: muted,
                fontSize: 18,
                fontWeight: 800,
                marginBottom: 8,
              }}
            >
              v{index}
            </div>
            <div
              style={{
                height: 58,
                borderRadius: 8,
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                margin: "0 4px",
                backgroundColor: part === 0 ? green : blue,
                color: "#ffffff",
                fontSize: 30,
                fontWeight: 900,
              }}
            >
              {part}
            </div>
          </div>
        ))}
      </div>
      <div
        style={{
          marginTop: 28,
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: 14,
        }}
      >
        <Metric label="objval" value="1 cut edge" color={coral} />
        <Metric label="nparts" value="2 blocks" color={green} />
      </div>
    </div>
  );
};

const Metric = ({
  label,
  value,
  color,
}: {
  label: string;
  value: string;
  color: string;
}) => (
  <div>
    <div
      style={{
        color,
        fontSize: 18,
        fontWeight: 850,
        letterSpacing: 0,
        textTransform: "uppercase",
        marginBottom: 5,
      }}
    >
      {label}
    </div>
    <div
      style={{
        color: ink,
        fontSize: 26,
        fontWeight: 850,
        lineHeight: 1.08,
      }}
    >
      {value}
    </div>
  </div>
);

const Capabilities = ({ frame }: { frame: number }) => {
  const visible = fade(frame, 382, 424);

  return (
    <div
      style={{
        position: "absolute",
        left: 88,
        right: 88,
        top: 735,
        opacity: visible,
        transform: `translateY(${move(frame, [382, 424], [34, 0])}px)`,
        display: "grid",
        gridTemplateColumns: "repeat(4, 1fr)",
        gap: 18,
      }}
    >
      {capabilityItems.map(([title, detail, color]) => (
        <div
          key={title}
          style={{
            ...panelStyle,
            padding: "24px 24px 26px",
            borderTop: `8px solid ${color}`,
          }}
        >
          <div
            style={{
              color: ink,
              fontSize: 28,
              fontWeight: 850,
              lineHeight: 1.05,
              marginBottom: 10,
            }}
          >
            {title}
          </div>
          <div
            style={{
              color: muted,
              fontSize: 21,
              fontWeight: 730,
              lineHeight: 1.18,
            }}
          >
            {detail}
          </div>
        </div>
      ))}
    </div>
  );
};

export const MetisOverview = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = frame / (fps * 15);

  return (
    <AbsoluteFill
      style={{
        backgroundColor: paper,
        fontFamily: "Inter, Avenir Next, Arial, sans-serif",
        overflow: "hidden",
      }}
    >
      <div
        style={{
          position: "absolute",
          inset: 0,
          background:
            "linear-gradient(135deg, rgba(40,120,215,0.08), rgba(36,149,91,0.07) 45%, rgba(239,96,75,0.06))",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 88,
          right: 88,
          top: 34,
          height: 8,
          borderRadius: 8,
          backgroundColor: "#dfe8dc",
        }}
      >
        <div
          style={{
            width: `${Math.min(100, progress * 100)}%`,
            height: "100%",
            borderRadius: 8,
            backgroundColor: coral,
          }}
        />
      </div>
      <Header frame={frame} />
      <CodeCard frame={frame} />
      <GraphScene frame={frame} />
      <MetisCall frame={frame} />
      <ResultMap frame={frame} />
      <Capabilities frame={frame} />
      <StoryBand frame={frame} />
    </AbsoluteFill>
  );
};
