import './App.css'
import { useEffect, useMemo, useState } from 'react'
import { installOneLiner, moduleCards, quickCommands } from './setupxData'
import { getComponentInstallCommand, getModuleAliasFromPath } from './setupxUtils'

const COPY_RESET_DELAY = 1600

function CopyStatusButton({
  command,
  copyState,
  onCopy,
  idleText,
  copiedText = 'Copied',
  failedText = 'Copy Failed',
}) {
  const isCopied = copyState.command === command && copyState.status === 'copied'
  const isFailed = copyState.command === command && copyState.status === 'failed'

  return (
    <button
      type="button"
      className={`btn btn-copy ${isFailed ? 'btn-copy-failed' : ''}`}
      onClick={onCopy}
    >
      {isCopied && copiedText}
      {isFailed && failedText}
      {!isCopied && !isFailed && idleText}
    </button>
  )
}

function HomeModuleCard({ module, isActive, copyState, onNavigate, onCopyModule }) {
  const moduleCommand = `sx ${module.alias}`

  return (
    <article
      className={`module-card ${isActive ? 'module-card-active' : ''}`}
      role="button"
      tabIndex={0}
      onClick={() => onNavigate(module.alias)}
      onKeyDown={(event) => {
        if (event.key === 'Enter' || event.key === ' ') {
          event.preventDefault()
          onNavigate(module.alias)
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
          <code>{moduleCommand}</code>
        </pre>
        <CopyStatusButton
          command={moduleCommand}
          copyState={copyState}
          idleText="Copy Module Install"
          onCopy={(event) => {
            event.stopPropagation()
            onCopyModule(module.alias)
          }}
        />
      </div>
    </article>
  )
}

function ComponentCard({ componentName, moduleAlias, modulePath, copyState, onCopyComponent }) {
  const command = getComponentInstallCommand(moduleAlias, componentName)

  return (
    <article className="component-card">
      <h3>{componentName}</h3>
      <p className="formula-label">Script: {modulePath}/{componentName}.ps1</p>
      <p className="formula-label">Component install formula</p>
      <pre>
        <code>{command}</code>
      </pre>
      <CopyStatusButton
        command={command}
        copyState={copyState}
        idleText="Copy Install Command"
        onCopy={() => onCopyComponent(moduleAlias, componentName)}
      />
    </article>
  )
}

function HomeView({
  totalComponents,
  activeModule,
  copyState,
  onNavigateToModule,
  onCopyModule,
  installOneLiner,
  copiedInstallLink,
  onCopyInstallLink,
}) {
  return (
    <>
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

      <section className="panel">
        <h2>Module Aliases</h2>
        <p className="panel-copy">Click a module to open its page and view all components with copy buttons.</p>
        <div className="module-grid">
          {moduleCards.map((module) => (
            <HomeModuleCard
              key={module.alias}
              module={module}
              isActive={activeModule?.alias === module.alias}
              copyState={copyState}
              onNavigate={onNavigateToModule}
              onCopyModule={onCopyModule}
            />
          ))}
        </div>
      </section>

      <section className="panel">
        <h2>Select A Module</h2>
        <p className="panel-copy">Choose any module card above to open its dedicated module page and list all components.</p>
      </section>

      <section className="panel">
        <h2>One-Command Installation</h2>
        <p className="panel-copy">Run this PowerShell command:</p>
        <div className="command-list">
          <pre>
            <code>{installOneLiner}</code>
          </pre>
        </div>
        <div className="install-inline-actions">
          <button type="button" className="btn btn-install-link" onClick={onCopyInstallLink}>
            {copiedInstallLink ? 'Install Command Copied' : 'Copy Install Command'}
          </button>
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
    </>
  )
}

function ModuleView({ activeModule, copyState, onCopyModule, onCopyComponent, onBackHome }) {
  const moduleCommand = `sx ${activeModule.alias}`

  return (
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
          <code>{moduleCommand}</code>
        </pre>
        <p>Install a component from this module</p>
        <pre>
          <code>sx install &lt;component-name&gt;</code>
        </pre>
      </div>

      <div className="module-page-command-bar">
        <pre>
          <code>{moduleCommand}</code>
        </pre>
        <CopyStatusButton
          command={moduleCommand}
          copyState={copyState}
          idleText="Copy Module Install"
          onCopy={() => onCopyModule(activeModule.alias)}
        />
      </div>

      <h3 className="component-subtitle">Components</h3>
      <button type="button" className="btn btn-ghost btn-back" onClick={onBackHome}>
        Back To Home
      </button>
      <div className="component-grid">
        {activeModule.components.map((componentName) => (
          <ComponentCard
            key={`${activeModule.alias}-${componentName}`}
            componentName={componentName}
            moduleAlias={activeModule.alias}
            modulePath={activeModule.path}
            copyState={copyState}
            onCopyComponent={onCopyComponent}
          />
        ))}
      </div>
    </section>
  )
}

function NotFoundView({ onBackHome }) {
  return (
    <section className="panel">
      <h2>Module Not Found</h2>
      <p className="panel-copy">This module page does not exist. Pick a module from the list above.</p>
      <button type="button" className="btn btn-ghost btn-back" onClick={onBackHome}>
        Back To Home
      </button>
    </section>
  )
}

function App() {
  const [routePath, setRoutePath] = useState(() => window.location.pathname)
  const [copyState, setCopyState] = useState({ command: '', status: 'idle' })
  const [copiedInstallLink, setCopiedInstallLink] = useState(false)

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
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), COPY_RESET_DELAY)
    } catch {
      setCopyState({ command, status: 'failed' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), COPY_RESET_DELAY)
    }
  }

  const handleCopyModuleCommand = async (moduleAlias) => {
    const command = `sx ${moduleAlias}`

    try {
      await copyText(command)
      setCopyState({ command, status: 'copied' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), COPY_RESET_DELAY)
    } catch {
      setCopyState({ command, status: 'failed' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), COPY_RESET_DELAY)
    }
  }

  const handleCopyInstallLink = async () => {
    try {
      await copyText(installOneLiner)
      setCopiedInstallLink(true)
      window.setTimeout(() => setCopiedInstallLink(false), COPY_RESET_DELAY)
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
        <HomeView
          totalComponents={totalComponents}
          activeModule={activeModule}
          copyState={copyState}
          onNavigateToModule={navigateToModule}
          onCopyModule={handleCopyModuleCommand}
          installOneLiner={installOneLiner}
          copiedInstallLink={copiedInstallLink}
          onCopyInstallLink={handleCopyInstallLink}
        />
      )}

      {activeModule && (
        <ModuleView
          activeModule={activeModule}
          copyState={copyState}
          onCopyModule={handleCopyModuleCommand}
          onCopyComponent={handleCopyCommand}
          onBackHome={navigateHome}
        />
      )}

      {isUnknownModuleRoute && <NotFoundView onBackHome={navigateHome} />}

      <footer className="footer">
        <p>SetupX • JSON-driven Windows setup automation</p>
      </footer>
    </div>
  )
}

export default App
