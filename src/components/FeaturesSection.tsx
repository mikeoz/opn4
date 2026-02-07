import { Eye, Zap, Shield, Waves } from "lucide-react";

const features = [
  {
    icon: Eye,
    title: "Photoreception",
    description: "Non-visual light detection that synchronizes with circadian rhythms.",
  },
  {
    icon: Zap,
    title: "Signal Transduction",
    description: "Rapid phototransduction cascade with millisecond precision.",
  },
  {
    icon: Shield,
    title: "Intrinsic Response",
    description: "Autonomous light sensitivity independent of rod and cone pathways.",
  },
  {
    icon: Waves,
    title: "Spectral Tuning",
    description: "Peak sensitivity at 480nm — the blue light wavelength.",
  },
];

const FeaturesSection = () => {
  return (
    <section className="relative py-32 px-6">
      <div className="max-w-5xl mx-auto">
        <p className="font-mono text-xs tracking-[0.3em] uppercase text-primary mb-4">
          Core Properties
        </p>
        <h2 className="text-3xl md:text-5xl font-bold tracking-tight text-foreground mb-16">
          Engineered for light
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {features.map((feature) => (
            <div
              key={feature.title}
              className="group p-8 rounded-xl border border-border bg-card hover:border-glow hover:box-glow transition-all duration-500"
            >
              <feature.icon className="w-6 h-6 text-primary mb-5" strokeWidth={1.5} />
              <h3 className="text-lg font-semibold text-foreground mb-2">{feature.title}</h3>
              <p className="text-sm text-muted-foreground leading-relaxed">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default FeaturesSection;
