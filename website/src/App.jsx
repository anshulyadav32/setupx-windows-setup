import './App.css'
import { useEffect, useMemo, useState } from 'react'
import { installOneLiner, moduleCards, quickCommands } from './setupxData'
import { getComponentInstallCommand, getModuleAliasFromPath } from './setupxUtils'

const COPY_RESET_DELAY = 1600

function CopyIcon() {
  return (
    <svg className="copy-icon" viewBox="0 0 24 24" width="16" height="16" aria-hidden="true" focusable="false">
      <path
        fill="currentColor"
        d="M16 1H4C2.9 1 2 1.9 2 3v14h2V3h12V1zm3 4H8C6.9 5 6 5.9 6 7v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"
      />
    </svg>
  )
}

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
      <span className="btn-with-icon">
        <CopyIcon />
        {isCopied && copiedText}
        {isFailed && failedText}
        {!isCopied && !isFailed && idleText}
      </span>
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

function CommandLinkCard({ title, value, href, copyState, onCopy }) {
  return (
    <article className="command-link-card">
      <h3>{title}</h3>
      {href ? (
        <a className="command-link-url" href={href} target="_blank" rel="noreferrer">
          {value}
        </a>
      ) : (
        <pre>
          <code>{value}</code>
        </pre>
      )}
      <CopyStatusButton
        command={value}
        copyState={copyState}
        idleText="Copy"
        copiedText="Copied"
        failedText="Copy Failed"
        onCopy={onCopy}
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
  readmeContent,
  onCopyText,
}) {
  const installAllManagersCommand =
    'Set-ExecutionPolicy Bypass -Scope Process -Force; iwr https://raw.githubusercontent.com/anshulyadav-git/setupx-windows-setup/main/install-all-pkgm.ps1 | iex'

  return (
    <>
      <section className="panel">
        <h2>README.md</h2>
        <p className="panel-copy">Website is synced with README content.</p>
        <pre className="readme-pre">
          <code>{readmeContent || 'Loading README...'}</code>
        </pre>
      </section>

      <section className="panel">
        <h2>sx - Modular Windows Development Setup</h2>
        <p className="panel-copy">A clean, modular PowerShell tool for setting up Windows development environments.</p>
        <h3 className="component-subtitle">About</h3>
        <p className="panel-copy">Live Website: https://setupx.vercel.app</p>
        <h3 className="component-subtitle">Quick Start</h3>
        <p className="formula-label">One-Command Installation</p>
        <div className="command-list">
          <pre>
            <code># Install sx with one command</code>
          </pre>
          <pre>
            <code>{installOneLiner}</code>
          </pre>
        </div>
        <p className="formula-label">One-Command Installation + Install All Package Managers</p>
        <div className="command-list">
          <pre>
            <code># Install sx and all package managers with one script</code>
          </pre>
          <pre>
            <code>{installAllManagersCommand}</code>
          </pre>
        </div>
        <p className="formula-label">Manual equivalent</p>
        <div className="command-list">
          <pre>
            <code>.\install.ps1; C:\\tools\\setupx\\sx.ps1 pgkm</code>
          </pre>
        </div>
      </section>

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
            <span className="btn-with-icon">
              <CopyIcon />
              {copiedInstallLink ? 'Install Command Copied' : 'Copy Install Command'}
            </span>
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

      <section className="panel">
        <h2>Links And Commands</h2>
        <p className="panel-copy">Website link and install command in one place.</p>
        <div className="command-link-grid">
          <CommandLinkCard
            title="Live Website"
            value="https://setupx.vercel.app"
            href="https://setupx.vercel.app"
            copyState={copyState}
            onCopy={() => onCopyText('https://setupx.vercel.app')}
          />
          <CommandLinkCard
            title="GitHub Repository"
            value="https://github.com/anshulyadav-git/setupx-windows-setup"
            href="https://github.com/anshulyadav-git/setupx-windows-setup"
            copyState={copyState}
            onCopy={() => onCopyText('https://github.com/anshulyadav-git/setupx-windows-setup')}
          />
          <CommandLinkCard
            title="Install Script"
            value="https://setupx.vercel.app/scripts/install.ps1"
            href="https://setupx.vercel.app/scripts/install.ps1"
            copyState={copyState}
            onCopy={() => onCopyText('https://setupx.vercel.app/scripts/install.ps1')}
          />
          <CommandLinkCard
            title="Install-All Script"
            value="https://setupx.vercel.app/scripts/install-all-pkgm.ps1"
            href="https://setupx.vercel.app/scripts/install-all-pkgm.ps1"
            copyState={copyState}
            onCopy={() => onCopyText('https://setupx.vercel.app/scripts/install-all-pkgm.ps1')}
          />
          <CommandLinkCard
            title="Winget Install Command"
            value="sx install winget"
            copyState={copyState}
            onCopy={() => onCopyText('sx install winget')}
          />
          <CommandLinkCard
            title="Install Command"
            value={installOneLiner}
            copyState={copyState}
            onCopy={() => onCopyText(installOneLiner)}
          />
        </div>
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
  const [readmeContent, setReadmeContent] = useState('')

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

  useEffect(() => {
    const loadReadme = async () => {
      try {
        const response = await fetch('/README.md')
        const text = await response.text()
        setReadmeContent(text)
      } catch {
        setReadmeContent('Unable to load README.md content.')
      }
    }

    loadReadme()
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

  const handleCopyText = async (text) => {
    try {
      await copyText(text)
      setCopyState({ command: text, status: 'copied' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), COPY_RESET_DELAY)
    } catch {
      setCopyState({ command: text, status: 'failed' })
      window.setTimeout(() => setCopyState({ command: '', status: 'idle' }), COPY_RESET_DELAY)
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
            <span className="btn-with-icon">
              <CopyIcon />
              {copiedInstallLink ? 'Install Link Copied' : 'Copy Install Link'}
            </span>
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
          readmeContent={readmeContent}
          onCopyText={handleCopyText}
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
