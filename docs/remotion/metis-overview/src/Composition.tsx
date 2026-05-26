import type { CSSProperties } from "react";
import {
  AbsoluteFill,
  Easing,
  interpolate,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

const ink = "#162022";
const muted = "#6a7477";
const paper = "#f7f3ea";
const panel = "#fffaf0";
const line = "#d9d0bd";
const blue = "#2f80ed";
const green = "#2d9f62";
const coral = "#ef6f5a";
const gold = "#d99a28";

const graphNodes = [
  { id: 0, x: 168, y: 122 },
  { id: 1, x: 82, y: 252 },
  { id: 2, x: 248, y: 278 },
  { id: 3, x: 452, y: 276 },
  { id: 4, x: 618, y: 250 },
  { id: 5, x: 532, y: 120 },
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

const codeLines = [
  "let graph = CsrGraph::new(",
  "  6,",
  "  [0, 2, 4, 7, 10, 12, 14],",
  "  [1, 2, 0, 2, 0, 1, 3,",
  "   2, 4, 5, 3, 5, 3, 4],",
  ")",
  "let result =",
  "  part_graph_kway(graph, 2)",
  "result.part  // [0, 0, 0, 1, 1, 1]",
];

const fade = (frame: number, start: number, end: number) =>
  interpolate(frame, [start, end], [0, 1], {
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

const SectionLabel = ({
  children,
  color,
}: {
  children: string;
  color: string;
}) => (
  <div
    style={{
      display: "inline-flex",
      alignItems: "center",
      gap: 12,
      color: ink,
      fontSize: 24,
      fontWeight: 700,
      letterSpacing: 0,
      lineHeight: 1,
    }}
  >
    <span
      style={{
        width: 12,
        height: 12,
        backgroundColor: color,
        borderRadius: 999,
      }}
    />
    {children}
  </div>
);

const Panel = ({
  children,
  style,
}: {
  children: React.ReactNode;
  style?: CSSProperties;
}) => (
  <div
    style={{
      backgroundColor: panel,
      border: `2px solid ${line}`,
      borderRadius: 8,
      boxShadow: "0 18px 50px rgba(34, 31, 25, 0.08)",
      ...style,
    }}
  >
    {children}
  </div>
);

const CodePanel = ({ frame }: { frame: number }) => {
  const reveal = codeLines.map((_, index) =>
    fade(frame, 44 + index * 9, 62 + index * 9),
  );
  const active = Math.min(
    codeLines.length - 1,
    Math.max(0, Math.floor((frame - 48) / 28)),
  );

  return (
    <Panel
      style={{
        position: "absolute",
        left: 86,
        top: 230,
        width: 610,
        height: 560,
        padding: "34px 34px 30px",
        opacity: fade(frame, 24, 54),
        transform: `translateY(${move(frame, [24, 64], [26, 0])}px)`,
      }}
    >
      <SectionLabel color={blue}>MoonBit input</SectionLabel>
      <div
        style={{
          marginTop: 30,
          padding: 26,
          backgroundColor: "#18252a",
          borderRadius: 8,
          color: "#ecf4f0",
          fontFamily: "Menlo, Consolas, monospace",
          fontSize: 25,
          lineHeight: 1.52,
          letterSpacing: 0,
        }}
      >
        {codeLines.map((lineText, index) => (
          <div
            key={lineText}
            style={{
              color: index === active ? "#ffe39a" : "#d5e4df",
              opacity: reveal[index],
              transform: `translateX(${(1 - reveal[index]) * -18}px)`,
              whiteSpace: "pre",
            }}
          >
            {lineText}
          </div>
        ))}
      </div>
    </Panel>
  );
};

const Graph = ({ frame }: { frame: number }) => {
  const graphIn = fade(frame, 82, 118);
  const partition = fade(frame, 220, 290);
  const bridgePulse =
    Math.sin(Math.max(0, frame - 198) / 9) * fade(frame, 198, 240);

  return (
    <Panel
      style={{
        position: "absolute",
        left: 770,
        top: 230,
        width: 700,
        height: 560,
        padding: "34px 36px",
        opacity: graphIn,
        transform: `translateY(${move(frame, [82, 128], [24, 0])}px)`,
      }}
    >
      <SectionLabel color={green}>Graph partitioning</SectionLabel>
      <svg
        viewBox="0 0 700 420"
        width="100%"
        height="420"
        style={{ marginTop: 24, overflow: "visible" }}
      >
        <rect
          x="18"
          y="14"
          width="310"
          height="356"
          rx="8"
          fill="#e9f4ec"
          opacity={partition * 0.9}
        />
        <rect
          x="352"
          y="14"
          width="310"
          height="356"
          rx="8"
          fill="#e8f0fb"
          opacity={partition * 0.9}
        />
        <text x="112" y="408" fill={green} fontSize="24" fontWeight="700">
          part 0
        </text>
        <text x="456" y="408" fill={blue} fontSize="24" fontWeight="700">
          part 1
        </text>
        {graphEdges.map(([from, to]) => {
          const a = graphNodes[from];
          const b = graphNodes[to];
          const isBridge = from === 2 && to === 3;
          return (
            <line
              key={`${from}-${to}`}
              x1={a.x}
              y1={a.y}
              x2={b.x}
              y2={b.y}
              stroke={isBridge ? coral : "#7f8f90"}
              strokeWidth={isBridge ? 8 + bridgePulse * 4 : 6}
              strokeLinecap="round"
              opacity={isBridge ? 0.35 + partition * 0.45 : 0.72}
            />
          );
        })}
        {graphNodes.map((node) => {
          const side = node.id <= 2 ? 0 : 1;
          const color = side === 0 ? green : blue;
          const neutralFill = "#fffaf0";
          const scale = 1 + partition * 0.1;
          return (
            <g
              key={node.id}
              transform={`translate(${node.x} ${node.y}) scale(${scale})`}
              opacity={graphIn}
            >
              <circle
                r="42"
                fill={partition > 0.02 ? color : neutralFill}
                stroke={partition > 0.02 ? "#ffffff" : ink}
                strokeWidth="6"
              />
              <text
                textAnchor="middle"
                dominantBaseline="central"
                fill={partition > 0.02 ? "#ffffff" : ink}
                fontSize="34"
                fontWeight="800"
              >
                {node.id}
              </text>
            </g>
          );
        })}
      </svg>
    </Panel>
  );
};

const MetisCore = ({ frame }: { frame: number }) => {
  const inProgress = fade(frame, 138, 184);
  const outputProgress = fade(frame, 250, 302);
  const pulse = 1 + Math.sin(frame / 7) * 0.025 * fade(frame, 150, 210);

  return (
    <>
      <div
        style={{
          position: "absolute",
          left: 690,
          top: 485,
          width: 86,
          height: 6,
          backgroundColor: coral,
          opacity: inProgress,
          transformOrigin: "left center",
          transform: `scaleX(${inProgress})`,
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 1458,
          top: 485,
          width: 86,
          height: 6,
          backgroundColor: coral,
          opacity: outputProgress,
          transformOrigin: "left center",
          transform: `scaleX(${outputProgress})`,
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 704,
          top: 820,
          width: 782,
          height: 90,
          borderRadius: 8,
          backgroundColor: "#18252a",
          color: "#fff7df",
          border: `2px solid ${coral}`,
          opacity: fade(frame, 142, 182),
          transform: `scale(${pulse})`,
          display: "flex",
          alignItems: "center",
          justifyContent: "space-between",
          padding: "0 38px",
          fontSize: 28,
          fontWeight: 750,
          letterSpacing: 0,
          boxShadow: "0 20px 50px rgba(24, 37, 42, 0.18)",
        }}
      >
        <span>METIS native C engine</span>
        <span style={{ color: "#ffd27d" }}>minimize edge cut</span>
      </div>
    </>
  );
};

const OutputPanel = ({ frame }: { frame: number }) => {
  const show = fade(frame, 272, 322);

  return (
    <Panel
      style={{
        position: "absolute",
        right: 86,
        top: 230,
        width: 330,
        height: 560,
        padding: "34px 30px",
        opacity: show,
        transform: `translateY(${move(frame, [272, 322], [28, 0])}px)`,
      }}
    >
      <SectionLabel color={gold}>MoonBit result</SectionLabel>
      <div
        style={{
          marginTop: 46,
          display: "grid",
          gap: 22,
          color: ink,
          fontSize: 31,
          fontWeight: 760,
          letterSpacing: 0,
        }}
      >
        <Metric label="objval" value="1 cut edge" color={coral} />
        <Metric label="part" value="[0,0,0,1,1,1]" color={blue} />
        <Metric label="nparts" value="2 balanced blocks" color={green} />
      </div>
    </Panel>
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
        fontSize: 19,
        fontWeight: 800,
        textTransform: "uppercase",
        letterSpacing: 0,
        marginBottom: 6,
      }}
    >
      {label}
    </div>
    <div style={{ lineHeight: 1.18 }}>{value}</div>
  </div>
);

const CapabilityStrip = ({ frame }: { frame: number }) => {
  const appear = fade(frame, 330, 372);
  const items = [
    ["CSR graphs", blue],
    ["Mesh to dual/nodal", green],
    ["NodeND ordering", gold],
    ["Safe validation", coral],
  ] as const;

  return (
    <div
      style={{
        position: "absolute",
        left: 86,
        right: 86,
        bottom: 62,
        opacity: appear,
        transform: `translateY(${move(frame, [330, 372], [34, 0])}px)`,
        display: "grid",
        gridTemplateColumns: "repeat(4, 1fr)",
        gap: 18,
      }}
    >
      {items.map(([item, color]) => (
        <div
          key={item}
          style={{
            borderTop: `8px solid ${color}`,
            backgroundColor: "#fffaf0",
            borderRadius: 8,
            padding: "22px 22px 24px",
            fontSize: 28,
            fontWeight: 760,
            color: ink,
            boxShadow: "0 16px 36px rgba(34, 31, 25, 0.08)",
          }}
        >
          {item}
        </div>
      ))}
    </div>
  );
};

const Header = ({ frame }: { frame: number }) => {
  const title = fade(frame, 0, 34);
  const subtitle = fade(frame, 18, 56);

  return (
    <div
      style={{
        position: "absolute",
        left: 86,
        right: 86,
        top: 58,
        display: "flex",
        alignItems: "flex-end",
        justifyContent: "space-between",
      }}
    >
      <div>
        <div
          style={{
            fontSize: 76,
            fontWeight: 860,
            color: ink,
            letterSpacing: 0,
            lineHeight: 0.92,
            opacity: title,
            transform: `translateY(${move(frame, [0, 34], [32, 0])}px)`,
          }}
        >
          Milky2018/metis
        </div>
        <div
          style={{
            marginTop: 20,
            fontSize: 31,
            fontWeight: 650,
            color: muted,
            opacity: subtitle,
            transform: `translateY(${move(frame, [18, 56], [22, 0])}px)`,
          }}
        >
          MoonBit bindings for graph partitioning, mesh conversion, and ordering
        </div>
      </div>
      <div
        style={{
          width: 282,
          height: 68,
          borderRadius: 8,
          border: `2px solid ${line}`,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: 25,
          fontWeight: 800,
          color: ink,
          backgroundColor: "#fffaf0",
          opacity: fade(frame, 36, 74),
        }}
      >
        15 second example
      </div>
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
            "linear-gradient(135deg, rgba(47,128,237,0.08), rgba(45,159,98,0.09) 46%, rgba(239,111,90,0.08))",
        }}
      />
      <div
        style={{
          position: "absolute",
          left: 86,
          right: 86,
          top: 36,
          height: 8,
          borderRadius: 8,
          backgroundColor: "#e5dcc9",
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
      <CodePanel frame={frame} />
      <Graph frame={frame} />
      <MetisCore frame={frame} />
      <OutputPanel frame={frame} />
      <CapabilityStrip frame={frame} />
    </AbsoluteFill>
  );
};
