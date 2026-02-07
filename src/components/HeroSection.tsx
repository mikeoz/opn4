const HeroSection = () => {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Radial glow background */}
      <div className="absolute inset-0 gradient-radial" />
      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] rounded-full bg-primary/5 blur-[120px] animate-pulse-glow" />

      <div className="relative z-10 text-center px-6 max-w-4xl mx-auto">
        <p className="font-mono text-sm tracking-[0.3em] uppercase text-primary mb-8 animate-pulse-glow">
          Photosensitive Protocol
        </p>

        <h1 className="text-7xl md:text-9xl font-bold tracking-tighter text-foreground text-glow mb-6">
          OPN4
        </h1>

        <p className="text-lg md:text-xl text-muted-foreground max-w-xl mx-auto leading-relaxed mb-12">
          A light-responsive system designed to sense, adapt, and illuminate. Built at the intersection of biology and technology.
        </p>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <button className="px-8 py-3 rounded-lg bg-primary text-primary-foreground font-medium tracking-wide hover:bg-primary/90 transition-all box-glow">
            Initialize
          </button>
          <button className="px-8 py-3 rounded-lg border border-glow text-primary font-medium tracking-wide hover:bg-primary/10 transition-all">
            Read the Signal
          </button>
        </div>
      </div>

      {/* Bottom fade */}
      <div className="absolute bottom-0 left-0 right-0 h-32 bg-gradient-to-t from-background to-transparent" />
    </section>
  );
};

export default HeroSection;
