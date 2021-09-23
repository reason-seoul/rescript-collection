const lightCodeTheme = require('prism-react-renderer/themes/github');
const darkCodeTheme = require('prism-react-renderer/themes/dracula');

// With JSDoc @type annotations, IDEs can provide config autocompletion
/** @type {import('@docusaurus/types').DocusaurusConfig} */
(module.exports = {
  title: 'ReScript Collection',
  tagline: 'Fast immutable collection for ReScript and JavaScript',
  url: 'https://rescript-collection.pages.dev',
  baseUrl: '/',
  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',
  favicon: 'img/rescript-favicon.png',
  organizationName: 'reason-seoul', // Usually your GitHub org/user name.
  projectName: 'rescript-collection', // Usually your repo name.

  presets: [
    [
      '@docusaurus/preset-classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve('./sidebars.js'),
          editUrl: 'https://github.com/reason-seoul/rescript-collection/edit/main/website/',
        },
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      navbar: {
        title: 'ReScript Collection',
        logo: {
          alt: 'ReScript Logo',
          src: 'img/rescript-brandmark.svg',
        },
        items: [
          {
            type: 'doc',
            docId: 'intro',
            position: 'left',
            label: 'Docs',
          },
          {
            href: 'https://github.com/reason-seoul/rescript-collection',
            label: 'GitHub',
            position: 'right',
          },
        ],
      },
      footer: {
        links: [
          {
            title: 'Docs',
            items: [
              {
                label: 'Introduction',
                to: '/docs/intro',
              },
            ],
          },
          {
            title: 'Packages',
            items: [
              {
                label: 'Vector',
                to: '/docs/packages/vector',
              },
              {
                label: 'HashMap',
                to: '/docs/packages/hashmap',
              },
              {
                label: 'HashSet',
                to: '/docs/packages/hashset',
              },
            ],
          },
          {
            title: 'Reason Seoul',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/reason-seoul',
              },
              {
                label: 'Discord',
                href: 'https://discord.gg/RzShCNp',
              },
              {
                label: 'Twitter',
                href: 'https://twitter.com/ReasonSeoul',
              },
              {
                label: 'Meetup',
                href: 'https://www.meetup.com/Reason-Seoul/',
              },
            ],
          },
          {
            title: 'More',
            items: [
              {
                label: 'GitHub',
                href: 'https://github.com/reason-seoul/rescript-collection',
              },
            ],
          },
        ],
        copyright: `Copyright © ${new Date().getFullYear()} Reason Seoul. Built with Docusaurus.`,
      },
      prism: {
        theme: lightCodeTheme,
        darkTheme: darkCodeTheme,
      },
    }),
});
