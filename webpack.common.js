const HtmlWebpackPlugin = require('html-webpack-plugin');
const { CleanWebpackPlugin } = require('clean-webpack-plugin');
const WebpackPwaManifest = require('webpack-pwa-manifest');

module.exports = {
  module: {
    rules: [
      {
        test: /\.html$/,
        use: 'html-loader',
      },
      {
        test: /\.css$/,
        use: [
          'style-loader',
          'css-loader',
        ],
      },
    ],
  },
  plugins: [
    new CleanWebpackPlugin(),
    new HtmlWebpackPlugin({
      template: 'public/index.html',
    }),
    new WebpackPwaManifest({
      name: 'Simple Checklist',
      short_name: 'Checklist',
      description: 'A simple checklist app',
      background_color: '#007bff',
      theme_color: '#007bff',
      ios: {
        'apple-mobile-web-app-status-bar-style': 'black',
      },
      icons: [
        {
          src: 'assets/ios-icon.png',
          sizes: [120, 152, 167, 180, 1024],
          ios: true,
        },
        {
          src: 'assets/android-icon.png',
          sizes: [36, 48, 72, 96, 144, 192, 512],
        },
      ],
    }),
  ],
};
