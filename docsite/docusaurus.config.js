// @ts-check

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "MrBogomips' Claude Code",
  tagline: 'Developer tools and plugins for Claude Code',
  favicon: 'img/favicon.ico',

  url: 'https://MrBogomips.github.io',
  baseUrl: '/claude-code/',

  organizationName: 'MrBogomips',
  projectName: 'claude-code',
  trailingSlash: false,

  onBrokenLinks: 'warn',

  markdown: {
    hooks: {
      onBrokenMarkdownLinks: 'warn',
    },
  },

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          path: '../docs',
          routeBasePath: '/',
          editUrl: 'https://github.com/MrBogomips/claude-code/edit/main/docs/',
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      colorMode: {
        defaultMode: 'dark',
        respectPrefersColorScheme: true,
      },
      navbar: {
        title: "MrBogomips' Claude Code",
        items: [
          {
            type: 'doc',
            docId: 'index',
            position: 'left',
            label: 'Home',
          },
          {
            type: 'dropdown',
            label: 'Plugins',
            position: 'left',
            items: [
              {
                to: '/devcontainer-generator',
                label: 'Devcontainer Generator',
              },
              {
                to: '/example-agents',
                label: 'Example Agents',
              },
              {
                to: '/example-skills',
                label: 'Example Skills',
              },
              {
                to: '/example-hooks',
                label: 'Example Hooks',
              },
            ],
          },
          {
            to: '/contributing',
            label: 'Contributing',
            position: 'left',
          },
          {
            href: 'https://github.com/MrBogomips/claude-code',
            position: 'right',
            className: 'header-github-link',
            'aria-label': 'GitHub repository',
          },
        ],
      },
      footer: {
        style: 'dark',
        links: [
          {
            title: 'Documentation',
            items: [
              {
                label: 'Home',
                to: '/',
              },
              {
                label: 'Devcontainer Generator',
                to: '/devcontainer-generator',
              },
              {
                label: 'Example Plugins',
                to: '/example-agents',
              },
            ],
          },
          {
            title: 'Resources',
            items: [
              {
                label: 'Claude Code Docs',
                href: 'https://docs.anthropic.com/en/docs/claude-code',
              },
              {
                label: 'Plugin Development',
                href: 'https://docs.anthropic.com/en/docs/claude-code/plugins',
              },
            ],
          },
          {
            title: 'Community',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/MrBogomips/claude-code',
              },
              {
                label: 'Issues',
                href: 'https://github.com/MrBogomips/claude-code/issues',
              },
            ],
          },
        ],
        copyright: `Copyright \u00a9 ${new Date().getFullYear()} Mr Bogomips.`,
      },
      prism: {
        additionalLanguages: ['bash', 'json', 'yaml', 'docker'],
      },
    }),
};

export default config;
