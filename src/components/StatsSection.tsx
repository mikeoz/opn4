const stats = [
  { value: "480nm", label: "Peak Wavelength" },
  { value: "~5%", label: "of Retinal Ganglion Cells" },
  { value: "10s", label: "Response Latency" },
  { value: "∞", label: "Sustained Firing" },
];

const StatsSection = () => {
  return (
    <section className="py-24 px-6 border-y border-border">
      <div className="max-w-5xl mx-auto grid grid-cols-2 md:grid-cols-4 gap-8">
        {stats.map((stat) => (
          <div key={stat.label} className="text-center">
            <p className="text-3xl md:text-4xl font-bold text-primary text-glow mb-2">
              {stat.value}
            </p>
            <p className="text-xs font-mono tracking-wider uppercase text-muted-foreground">
              {stat.label}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
};

export default StatsSection;
