const installTargetOverrides = {
  pgkm: {
    choco: 'chocolatey',
  },
}

export const getModuleAliasFromPath = (pathname) => {
  const match = pathname.match(/^\/module\/([a-z0-9-]+)\/?$/i)
  return match ? decodeURIComponent(match[1]).toLowerCase() : null
}

export const getInstallTarget = (moduleAlias, componentName) => {
  return installTargetOverrides[moduleAlias]?.[componentName] ?? componentName
}

export const getComponentInstallCommand = (moduleAlias, componentName) => {
  return `setupx install ${getInstallTarget(moduleAlias, componentName)}`
}

