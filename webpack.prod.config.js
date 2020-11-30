const merge = require('webpack-merge')
const webpackBase = require('./webpack.config')
const CompressionWebPackPlugin = require('compression-webpack-plugin')
const WorkboxPlugin = require('workbox-webpack-plugin')
const webpack = require('webpack')
const rimraf = require('rimraf')
const fs = require('fs')
const Dotenv = require("dotenv-webpack");

if (fs.existsSync('./dist')) {
  rimraf('./dist', () => console.log('./dist removed'))
}

module.exports = merge(webpackBase, {
  plugins: [
    new CompressionWebPackPlugin({
      test: /\.js/
    }),
    new WorkboxPlugin.GenerateSW(),
    new webpack.DefinePlugin({
      'process.env': {
        'NODE_ENV': "'production'"
      }
    }),
    new Dotenv({
      systemvars: true,
    }),
  ]
})