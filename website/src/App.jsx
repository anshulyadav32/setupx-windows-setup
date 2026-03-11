import './App.css'

const moduleCards = [
  { alias: 'pgkm', name: 'Package Managers', path: 'scripts/pgkm', components: 20 },
  { alias: 'wdev', name: 'Web Development', path: 'scripts/wdev', components: 7 },
  { alias: 'aidve', name: 'AI Development', path: 'scripts/aidve', components: 11 },
  { alias: 'mdev', name: 'Mobile Development', path: 'scripts/mdev', components: 3 },
  { alias: 'wsl', name: 'WSL Linux', path: 'scripts/wsl', components: 3 },
  { alias: 'cdev', name: 'Cloud Development', path: 'scripts/cdev', components: 5 },
  { alias: 'codev', name: 'Common Development', path: 'scripts/codev', components: 14 },
  { alias: 'devops', name: 'DevOps', path: 'scripts/devops', components: 3 },
  { alias: 'dscience', name: 'Data Science', path: 'scripts/dscience', components: 4 },
]

const quickCommands = [
  'Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1 | iex',
  'sx pgkm',
  'sx wdev',
  'sx aidev',
  'sx mdev',
  'sx wsl',
  'sx cdev',
  'sx codev',
  'sx devops',
  'sx dscience',
]

function App() {
  const totalComponents = moduleCards.reduce((sum, module) => sum + module.components, 0)

  return (
    <div className="site-shell">
      <header className="hero">
        <p className="eyebrow">Windows Automation Platform</p>
        <h1>SetupX</h1>
        <p className="hero-copy">
          One command setup for full developer environments. Built for speed, scriptability,
          and repeatable team onboarding.
        </p>
        <div className="hero-actions">
          <a className="btn btn-primary" href="https://setupx.vercel.app" target="_blank" rel="noreferrer">
            Live Site
          </a>
          <a
            className="btn btn-ghost"
            href="https://github.com/anshulyadav-git/setupx-windows-setup"
            target="_blank"
            rel="noreferrer"
          >
            GitHub Repo
          </a>
        </div>
      </header>

      <section className="stats-grid">
        <article>
          <strong>9</strong>
          <span>Modules</span>
        </article>
        <article>
          <strong>{totalComponents}</strong>
          <span>Total Components</span>
        </article>
        <article>
          <strong>1</strong>
          <span>Unified CLI: sx</span>
        </article>
      </section>

      <section className="panel">
        <h2>Module Aliases</h2>
        <div className="module-grid">
          {moduleCards.map((module) => (
            <article key={module.alias} className="module-card">
              <h3>{module.name}</h3>
              <p>Alias: {module.alias}</p>
              <p>Scripts: {module.path}</p>
              <p>Components: {module.components}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="panel">
        <h2>Quick Commands</h2>
        <div className="command-list">
          {quickCommands.map((command) => (
            <pre key={command}>
              <code>{command}</code>
            </pre>
          ))}
        </div>
      </section>

      <section className="panel timeline">
        <h2>How SetupX Works</h2>
        <ol>
          <li>Install once with PowerShell one-liner.</li>
          <li>Pick a module alias like pgkm, wdev, or dscience.</li>
          <li>Run sx &lt;alias&gt; for full setup or sx install &lt;component&gt; for targeted install.</li>
          <li>Use per-component scripts in scripts folders for direct automation workflows.</li>
        </ol>
      </section>

      <footer className="footer">
        <p>SetupX • JSON-driven Windows setup automation</p>
      </footer>
    </div>
  )
}

export default App
