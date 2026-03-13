import './App.css'
import { useMemo, useState } from 'react'

const installOneLiner =
  'iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1 | iex'
const installAllOneLiner =
  'Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex'

const whyItems = [
  ['One-command install', 'Bootstrap your environment with one PowerShell command.'],
  ['Modular architecture', 'Install only what you need, from one component to full stacks.'],
  ['JSON-driven config', 'Tool and module definitions are versioned and auditable.'],
  ['Package manager support', 'Unified flow for Chocolatey, Scoop, WinGet, npm, and more.'],
  ['Quick setup profiles', 'Use presets for full-stack, web-dev, cloud-dev, and ai-dev.'],
  ['Testing and status checks', 'Built-in validation commands to verify your setup.'],
]

const featureRows = [
  ['Install package managers', 'sx pkgm'],
  ['List available commands and modules', 'sx list'],
  ['Check current setup health', 'sx status'],
  ['See module components', 'sx components web-development'],
  ['Install complete module', 'install-module web-development'],
  ['Install specific component', 'install-component pgkm chocolatey'],
  ['Run quick setup profile', 'quick-setup full-stack'],
]

const modules = [
  { name: 'Package Managers', alias: 'pgkm', details: 'Chocolatey, Scoop, Winget, npm, yarn, pnpm and more.' },
  { name: 'Web Development', alias: 'web-development', details: 'Frontend tooling, browsers, frameworks, and build tools.' },
  { name: 'Mobile Development', alias: 'mobile-development', details: 'Flutter, mobile CLIs, and mobile-ready dev stack.' },
  { name: 'Backend Development', alias: 'backend-development', details: 'Core backend runtimes, SDKs, and server tooling.' },
  { name: 'Cloud Development', alias: 'cloud-development', details: 'AWS, Azure, GCP, terraform, kubectl workflows.' },
  { name: 'Common Development', alias: 'common-development', details: 'Git, VS Code, terminal, browsers, and daily essentials.' },
  { name: 'AI Development Tools', alias: 'ai-development-tools', details: 'AI CLIs, model workflows, and inference-friendly setup.' },
  { name: 'Data Science', alias: 'data-science', details: 'Python stack, notebooks, data tooling, and ML basics.' },
  { name: 'Game Development', alias: 'game-development', details: 'Starter module for game-dev runtime and engine tooling.' },
  { name: 'DevOps', alias: 'devops', details: 'Automation, pipelines, infra-as-code, and deployment tools.' },
  { name: 'Security', alias: 'security', details: 'Security analysis and hardening toolchain presets.' },
  { name: 'Blockchain', alias: 'blockchain', details: 'Web3 tooling, CLIs, and chain development prerequisites.' },
  { name: 'WSL/Linux', alias: 'wsl-linux', details: 'WSL, distro setup, and Linux-based development workflows.' },
]

const presets = [
  ['full-stack', 'Package managers + web + backend'],
  ['web-dev', 'Package managers + frontend tooling'],
  ['mobile-dev', 'Package managers + mobile stack'],
  ['cloud-dev', 'Package managers + cloud tooling'],
  ['ai-dev', 'Package managers + AI and ML tooling'],
]

const commandTabs = {
  core: ['sx status', 'sx list', 'sx components web-development'],
  modules: ['install-module pgkm', 'install-module web-development', 'install-module cloud-development'],
  components: ['install-component pgkm chocolatey', 'install-component web-development nodejs', 'install-component web-development yarn'],
  testing: ['test-module pgkm', 'test-component web-development nodejs', 'check-status'],
}

const benefits = [
  'Save setup time from hours to minutes',
  'Keep environments repeatable and consistent',
  'Avoid manual configuration mistakes',
  'Onboard faster on new machines',
  'Scale your personal or team setup workflow',
]

const faqs = [
  ['Is SetupX Windows-only?', 'Yes. SetupX targets Windows environments and integrates with Windows-native tooling.'],
  ['Does it require admin permissions?', 'Some installations need elevated permissions. SetupX handles mixed privilege workflows where possible.'],
  ['Can I install only selected modules?', 'Yes. Use module and component commands to install only what you need.'],
  ['How do I test what was installed?', 'Use test-module, test-component, sx status, and check-status commands.'],
]

function CopyButton({ value, copied, onCopy }) {
  return (
    <button type="button" className="copy-btn" onClick={() => onCopy(value)}>
      {copied ? 'Copied' : 'Copy'}
    </button>
  )
}

function CommandCard({ title, value, onCopy, copied }) {
  return (
    <article className="command-card">
      <h4>{title}</h4>
      <pre>
        <code>{value}</code>
      </pre>
      <CopyButton value={value} copied={copied} onCopy={onCopy} />
    </article>
  )
}

function App() {
  const [copiedValue, setCopiedValue] = useState('')
  const [openModule, setOpenModule] = useState(modules[0].alias)
  const [activeTab, setActiveTab] = useState('core')

  const totals = useMemo(
    () => ({ modules: modules.length, presets: presets.length, commands: Object.values(commandTabs).flat().length }),
    [],
  )

  const copyText = async (value) => {
    try {
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(value)
      } else {
        const ta = document.createElement('textarea')
        ta.value = value
        ta.style.position = 'absolute'
        ta.style.left = '-9999px'
        document.body.appendChild(ta)
        ta.select()
        document.execCommand('copy')
        document.body.removeChild(ta)
      }
      setCopiedValue(value)
      window.setTimeout(() => setCopiedValue(''), 1400)
    } catch {
      setCopiedValue('')
    }
  }

  return (
    <div className="landing-shell">
      <header className="hero" id="top">
        <p className="eyebrow">SetupX / sx</p>
        <h1>Set up your Windows dev environment in one command</h1>
        <p className="hero-copy">
          SetupX is a modular PowerShell tool for automating installation of package managers,
          frameworks, and developer tools using a clean JSON-driven workflow.
        </p>
        <p className="sub-tagline">Automate your Windows dev environment with one command.</p>
        <div className="hero-actions">
          <a className="btn btn-primary" href="#quick-start">Get Started</a>
          <a className="btn btn-ghost" href="https://github.com/anshulyadav-git/setupx-windows-setup" target="_blank" rel="noreferrer">
            View on GitHub
          </a>
        </div>
        <div className="hero-terminal">
          <CommandCard title="Install SetupX" value={installOneLiner} onCopy={copyText} copied={copiedValue === installOneLiner} />
          <CommandCard title="Install SetupX + Package Managers" value={installAllOneLiner} onCopy={copyText} copied={copiedValue === installAllOneLiner} />
        </div>
      </header>

      <section className="section" id="why">
        <h2>Why SetupX</h2>
        <div className="feature-grid">
          {whyItems.map(([title, text]) => (
            <article key={title} className="feature-card">
              <h3>{title}</h3>
              <p>{text}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="features">
        <h2>Core Features</h2>
        <div className="feature-list">
          {featureRows.map(([label, command]) => (
            <article key={label} className="feature-row">
              <div>
                <h3>{label}</h3>
              </div>
              <pre>
                <code>{command}</code>
              </pre>
              <CopyButton value={command} copied={copiedValue === command} onCopy={copyText} />
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="modules">
        <h2>Modules / Ecosystem</h2>
        <div className="module-grid">
          {modules.map((mod) => (
            <article key={mod.alias} className={`module-card ${openModule === mod.alias ? 'open' : ''}`}>
              <button type="button" className="module-toggle" onClick={() => setOpenModule(openModule === mod.alias ? '' : mod.alias)}>
                <span>{mod.name}</span>
                <small>{mod.alias}</small>
              </button>
              {openModule === mod.alias && (
                <div className="module-body">
                  <p>{mod.details}</p>
                  <pre>
                    <code>{`install-module ${mod.alias}`}</code>
                  </pre>
                  <CopyButton value={`install-module ${mod.alias}`} copied={copiedValue === `install-module ${mod.alias}`} onCopy={copyText} />
                </div>
              )}
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="presets">
        <h2>Quick Setup Presets</h2>
        <div className="preset-grid">
          {presets.map(([name, desc]) => (
            <article key={name} className="preset-card">
              <h3>{name}</h3>
              <p>{desc}</p>
              <pre>
                <code>{`quick-setup ${name}`}</code>
              </pre>
              <CopyButton value={`quick-setup ${name}`} copied={copiedValue === `quick-setup ${name}`} onCopy={copyText} />
            </article>
          ))}
        </div>
      </section>

      <section className="section" id="how">
        <h2>How It Works</h2>
        <ol className="steps">
          <li>
            <strong>Install SetupX</strong>
            <span>Run the one-command installer to bootstrap sx.</span>
          </li>
          <li>
            <strong>Choose a module or preset</strong>
            <span>Install a targeted stack or a quick setup profile.</span>
          </li>
          <li>
            <strong>Verify with testing commands</strong>
            <span>Confirm your environment with status and test commands.</span>
          </li>
        </ol>
      </section>

      <section className="section" id="commands">
        <h2>Command Showcase</h2>
        <div className="tabs">
          {[
            ['core', 'Core Commands'],
            ['modules', 'Module Installs'],
            ['components', 'Component Installs'],
            ['testing', 'Status / Testing'],
          ].map(([key, label]) => (
            <button key={key} type="button" className={`tab ${activeTab === key ? 'active' : ''}`} onClick={() => setActiveTab(key)}>
              {label}
            </button>
          ))}
        </div>
        <div className="terminal-showcase">
          {commandTabs[activeTab].map((cmd) => (
            <div key={cmd} className="terminal-line">
              <code>{cmd}</code>
              <CopyButton value={cmd} copied={copiedValue === cmd} onCopy={copyText} />
            </div>
          ))}
        </div>
      </section>

      <section className="section" id="benefits">
        <h2>Benefits</h2>
        <ul className="benefits">
          {benefits.map((item) => (
            <li key={item}>{item}</li>
          ))}
        </ul>
      </section>

      <section className="section" id="open-source">
        <h2>Open Source</h2>
        <p>
          SetupX is open source and hosted on GitHub. Explore the code, review the scripts,
          and contribute improvements.
        </p>
        <div className="hero-actions">
          <a className="btn btn-primary" href="https://github.com/anshulyadav-git/setupx-windows-setup" target="_blank" rel="noreferrer">
            Star on GitHub
          </a>
          <a className="btn btn-ghost" href="https://github.com/anshulyadav-git/setupx-windows-setup#readme" target="_blank" rel="noreferrer">
            Explore Docs
          </a>
          <a className="btn btn-ghost" href="https://github.com/anshulyadav-git/setupx-windows-setup/pulls" target="_blank" rel="noreferrer">
            Contribute
          </a>
        </div>
      </section>

      <section className="section" id="faq">
        <h2>FAQ</h2>
        <div className="faq-list">
          {faqs.map(([q, a]) => (
            <article key={q} className="faq-card">
              <h3>{q}</h3>
              <p>{a}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="section stats-inline" id="quick-start">
        <article>
          <strong>{totals.modules}</strong>
          <span>Modules</span>
        </article>
        <article>
          <strong>{totals.presets}</strong>
          <span>Presets</span>
        </article>
        <article>
          <strong>{totals.commands}</strong>
          <span>Showcased Commands</span>
        </article>
      </section>

      <footer className="footer">
        <a href="https://github.com/anshulyadav-git/setupx-windows-setup" target="_blank" rel="noreferrer">
          GitHub
        </a>
        <a href="https://github.com/anshulyadav-git/setupx-windows-setup#readme" target="_blank" rel="noreferrer">
          Documentation
        </a>
        <a href="https://setupx.vercel.app" target="_blank" rel="noreferrer">
          Website
        </a>
        <span>Maintainer: anshulyadav-git</span>
        <span>Open source under MIT license</span>
      </footer>
    </div>
  )
}

export default App
