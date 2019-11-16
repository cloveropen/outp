module.exports = {
  performance: {
    hints: false, // 枚举 false关闭
    maxEntrypointSize: 50000000, //入口文件的最大体积，单位字节
    maxAssetSize: 30000000, //生成文件的最大体积，单位字节
    assetFilter: function(assetFilename) {
      //只给出js文件的性能提示
      return assetFilename.endsWith(".js");
    }
  }
};
