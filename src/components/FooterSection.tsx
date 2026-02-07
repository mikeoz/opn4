const FooterSection = () => {
  return (
    <footer className="py-16 px-6 border-t border-border">
      <div className="max-w-5xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6">
        <p className="text-2xl font-bold tracking-tighter text-foreground">OPN4</p>
        <p className="text-xs font-mono text-muted-foreground tracking-wider">
          © 2026 OPN4 — Light is information
        </p>
      </div>
    </footer>
  );
};

export default FooterSection;
