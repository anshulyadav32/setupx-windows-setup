import './App.css'
import { useEffect, useMemo, useState } from 'react'

const moduleCards = [
  {
    alias: 'pgkm',
    name: 'Package Managers',
    path: 'scripts/pgkm',
    components: [
      'bun',
      'cargo',
      'choco',
      'chocolatey',
      'composer',
      'conda',
      'dotnet-tool',
      'gem',
      'go',
      'mamba',
      'nodejs',
      'npm',
      'nuget',
      'nvm',
      'pip',
      'pipx',
      'pnpm',
      'scoop',
      'vcpkg',
      'winget',
      'yarn',
    ],
  },
  {
    alias: 'wdev',
    name: 'Web Development',
    path: 'scripts/wdev',
    components: ['angular-tools', 'browsers', 'nodejs', 'react-tools', 'vite', 'vue-tools', 'yarn'],
  },
  {
    alias: 'aidve',
    name: 'AI Development',
    path: 'scripts/aidve',
    components: [
      'aws-cli',
      'azure-cli',
      'codex-cli',
      'gcloud-cli',
      'grok-cli',
      'netlify-cli',
      'node',
      'python',
      'redis',
      'vercel-cli',
      'xampp',
    ],
  },
  { alias: 'mdev', name: 'Mobile Development', path: 'scripts/mdev', components: ['android-studio', 'flutter', 'react-native-cli'] },
  { alias: 'wsl', name: 'WSL Linux', path: 'scripts/wsl', components: ['docker-desktop', 'ubuntu', 'wsl'] },
  { alias: 'cdev', name: 'Cloud Development', path: 'scripts/cdev', components: ['aws-cli', 'azure-cli', 'gcloud-cli', 'kubectl', 'terraform'] },
  {
    alias: 'codev',
    name: 'Common Development',
    path: 'scripts/codev',
    components: [
      '7zip',
      'brave',
      'chrome',
      'firefox',
      'gh',
      'git',
      'github-desktop',
      'jdk',
      'powershell',
      'powertoys',
      'telegram',
      'vscode',
      'whatsapp',
      'windows-terminal',
    ],
  },
  { alias: 'devops', name: 'DevOps', path: 'scripts/devops', components: ['ansible', 'jenkins', 'terraform'] },
  { alias: 'dscience', name: 'Data Science', path: 'scripts/dscience', components: ['jupyter', 'pandas', 'pytorch', 'tensorflow'] },
]

const quickCommands = [
  'Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1 | iex',
  'sx pgkm',
  'sx wdev',
  'sx aidve',
  'sx mdev',
  'sx wsl',
  'sx cdev',
  'sx codev',
  'sx devops',
  'sx dscience',
]

const getModuleAliasFromPath = (pathname) => {
  const match = pathname.match(/^\/module\/([a-z0-9-]+)\/?$/i)
  return match ? decodeURIComponent(match[1]).toLowerCase() : null
}

function App() {
  const [routePath, setRoutePath] = useState(() => window.location.pathname)
  const [copyState, setCopyState] = useState({ command: '', status: 'idle' })
  const [copiedInstallLink, setCopiedInstallLink] = useState(false)

  const installOneLiner =
    'Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install.ps1 | iex'

  const totalComponents = moduleCards.reduce((sum, module) => sum + module.components.length, 0)
  const routeModuleAlias = useMemo(() => getModuleAliasFromPath(routePath), [routePath])
  const activeModule = useMemo(
    () => moduleCards.find((module) => module.alias === routeModuleAlias) ?? null,
    [routeModuleAlias],
  )
  const isModuleRoute = routeModuleAlias !== null
  const isHomeRoute = !isModuleRoute
  const isUnknownModuleRoute = isModuleRoute && !activeModule

  useEffect(() => {
    if (activeModule) {
      document.title = `SetupX | ${activeModule.name}`
      return
    }

    document.title = 'SetupX'
  }, [activeModule])

  useEffect(() => {
    const handlePopState = () => setRoutePath(window.location.pathname)
    window.addEventListener('popstate', handlePopState)

    return () => window.removeEventListener('popstate', handlePopState)
  }, [])

  const navigateToModule = (moduleAlias) => {
    const nextPath = `/module/${moduleAlias}`
    window.location.assign(nextPath)
  }

  const navigateHome = () => {
    if (window.location.pathname === '/') {
      return
    }

    window.history.pushState({}, '', '/')
    setRoutePath('/')
  }

  const getInstallTarget = (moduleAlias, componentName) => {
    const overrides = {
      pgkm: {
        choco: 'chocolatey',
      },
    }

    return overrides[moduleAlias]?.[componentName] ?? componentName
  }

  const getComponentInstallCommand = (moduleAlias, componentName) => `sx install ${getInstallTarget(moduleAlias, componentName)}`

  const fallbackCopyText = (text) => {
    const textarea = document.createElement('textarea')
    textarea.value = text
    textarea.setAttribute('readonly', '')
    textarea.style.position = 'absolute'
    textarea.style.left = '-9999px'
    document.body.appendChild(textarea)
    textarea.select()
    const copied = document.execCommand('copy')
    document.body.removeChild(textarea)
    return copied
  }

  const copyText = async (text) => {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text)
      return
    }

    const copied = fallbackCopyText(text)
    if (!copied) {
      throw new Error('Clipboard copy failed')
    }
  }

  const handleCopyCommand = async (moduleAlias, componentName) => {
    const command = getComponentInstallCommand(moduleAlias, componentName)

    try {
      await copyText(command)

      setCopyState({ command, status: 'copied' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), 1600)
    } catch {
      setCopyState({ command, status: 'failed' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), 1600)
    }
  }

  const handleCopyModuleCommand = async (moduleAlias) => {
    const command = `sx ${moduleAlias}`

    try {
      await copyText(command)
      setCopyState({ command, status: 'copied' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), 1600)
    } catch {
      setCopyState({ command, status: 'failed' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), 1600)
    }
  }

  const handleCopyInstallLink = async () => {
    try {
      await copyText(installOneLiner)
      setCopiedInstallLink(true)
      window.setTimeout(() => setCopiedInstallLink(false), 1600)
    } catch {
      setCopiedInstallLink(false)
    }
  }

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
          <button type="button" className="btn btn-install-link" onClick={handleCopyInstallLink}>
            {copiedInstallLink ? 'Install Link Copied' : 'Copy Install Link'}
          </button>
        </div>
      </header>

      {isHomeRoute && (
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
      )}

      {isHomeRoute && (
        <section className="panel">
          <h2>Module Pages</h2>
          <p className="panel-copy">Open any module page directly:</p>
          <div className="module-page-links">
            {moduleCards.map((module) => (
              <a key={module.alias} className="module-page-link" href={`/module/${module.alias}`}>
                <span>{module.name}</span>
                <small>/module/{module.alias}</small>
              </a>
            ))}
          </div>
        </section>
      )}

      {isHomeRoute && (
        <section className="panel">
          <h2>Module Aliases</h2>
          <p className="panel-copy">Click a module to open its page and view all components with copy buttons.</p>
          <div className="module-grid">
            {moduleCards.map((module) => (
              <article
                key={module.alias}
                className={`module-card ${activeModule?.alias === module.alias ? 'module-card-active' : ''}`}
                role="button"
                tabIndex={0}
                onClick={() => navigateToModule(module.alias)}
                onKeyDown={(event) => {
                  if (event.key === 'Enter' || event.key === ' ') {
                    event.preventDefault()
                    navigateToModule(module.alias)
                  }
                }}
              >
                <h3>{module.name}</h3>
                <p>Alias: {module.alias}</p>
                <p>Scripts: {module.path}</p>
                <p>Components: {module.components.length}</p>
                <p>Page: /module/{module.alias}</p>
                <div className="module-card-actions">
                  <pre>
                    <code>{`sx ${module.alias}`}</code>
                  </pre>
                  <button
                    type="button"
                    className={`btn btn-copy ${copyState.command === `sx ${module.alias}` && copyState.status === 'failed' ? 'btn-copy-failed' : ''}`}
                    onClick={(event) => {
                      event.stopPropagation()
                      handleCopyModuleCommand(module.alias)
                    }}
                  >
                    {copyState.command === `sx ${module.alias}` && copyState.status === 'copied' && 'Copied'}
                    {copyState.command === `sx ${module.alias}` && copyState.status === 'failed' && 'Copy Failed'}
                    {(copyState.command !== `sx ${module.alias}` || copyState.status === 'idle') && 'Copy Module Install'}
                  </button>
                </div>
              </article>
            ))}
          </div>
        </section>
      )}

      {activeModule && (
        <section className="panel">
          <p className="eyebrow module-page-eyebrow">Dedicated Module Page</p>
          <div className="component-heading-row">
            <h2>{activeModule.name}</h2>
            <span className="badge">{activeModule.components.length} items</span>
          </div>
          <p className="panel-copy">Alias: {activeModule.alias}</p>
          <p className="panel-copy">Path: {activeModule.path}</p>
          <p className="panel-copy">Module page: /module/{activeModule.alias}</p>
          <div className="module-details-grid">
            <article>
              <strong>Module Name</strong>
              <p>{activeModule.name}</p>
            </article>
            <article>
              <strong>Module Alias</strong>
              <p>{activeModule.alias}</p>
            </article>
            <article>
              <strong>Components</strong>
              <p>{activeModule.components.length}</p>
            </article>
            <article>
              <strong>Scripts Path</strong>
              <p>{activeModule.path}</p>
            </article>
          </div>
          <div className="formula-box">
            <h3>Installation Formula</h3>
            <p>Install full module</p>
            <pre>
              <code>{`sx ${activeModule.alias}`}</code>
            </pre>
            <p>Install a component from this module</p>
            <pre>
              <code>sx install &lt;component-name&gt;</code>
            </pre>
          </div>
          <div className="module-page-command-bar">
            <pre>
              <code>{`sx ${activeModule.alias}`}</code>
            </pre>
            <button
              type="button"
              className={`btn btn-copy ${copyState.command === `sx ${activeModule.alias}` && copyState.status === 'failed' ? 'btn-copy-failed' : ''}`}
              onClick={() => handleCopyModuleCommand(activeModule.alias)}
            >
              {copyState.command === `sx ${activeModule.alias}` && copyState.status === 'copied' && 'Copied'}
              {copyState.command === `sx ${activeModule.alias}` && copyState.status === 'failed' && 'Copy Failed'}
              {(copyState.command !== `sx ${activeModule.alias}` || copyState.status === 'idle') && 'Copy Module Install'}
            </button>
          </div>
          <h3 className="component-subtitle">Components</h3>
          <button type="button" className="btn btn-ghost btn-back" onClick={navigateHome}>
            Back To Home
          </button>
          <div className="component-grid">
            {activeModule.components.map((componentName) => {
              const command = getComponentInstallCommand(activeModule.alias, componentName)

              return (
                <article key={`${activeModule.alias}-${componentName}`} className="component-card">
                  <h3>{componentName}</h3>
                  <p className="formula-label">Script: {activeModule.path}/{componentName}.ps1</p>
                  <p className="formula-label">Component install formula</p>
                  <pre>
                    <code>{command}</code>
                  </pre>
                  <button
                    type="button"
                    className={`btn btn-copy ${copyState.command === command && copyState.status === 'failed' ? 'btn-copy-failed' : ''}`}
                    onClick={() => handleCopyCommand(activeModule.alias, componentName)}
                  >
                    {copyState.command === command && copyState.status === 'copied' && 'Copied'}
                    {copyState.command === command && copyState.status === 'failed' && 'Copy Failed'}
                    {(copyState.command !== command || copyState.status === 'idle') && 'Copy Install Command'}
                  </button>
                </article>
              )
            })}
          </div>
        </section>
      )}

      {!isModuleRoute && (
        <section className="panel">
          <h2>Select A Module</h2>
          <p className="panel-copy">Choose any module card above to open its dedicated module page and list all components.</p>
        </section>
      )}

      {isUnknownModuleRoute && (
        <section className="panel">
          <h2>Module Not Found</h2>
          <p className="panel-copy">This module page does not exist. Pick a module from the list above.</p>
          <button type="button" className="btn btn-ghost btn-back" onClick={navigateHome}>
            Back To Home
          </button>
        </section>
      )}

      {isHomeRoute && (
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
      )}

      {isHomeRoute && (
        <section className="panel timeline">
          <h2>How SetupX Works</h2>
          <ol>
            <li>Install once with PowerShell one-liner.</li>
            <li>Pick a module alias like pgkm, wdev, or dscience.</li>
            <li>Run sx &lt;alias&gt; for full setup or sx install &lt;component&gt; for targeted install.</li>
            <li>Use per-component scripts in scripts folders for direct automation workflows.</li>
          </ol>
        </section>
      )}

      <footer className="footer">
        <p>SetupX • JSON-driven Windows setup automation</p>
      </footer>
    </div>
  )
}

export default App
