var os = require("os")

// CPU 的字节序
console.log('endianness : ' + os.endianness());
 
// 操作系统名
console.log('type : ' + os.type());
 
// 操作系统名
console.log('platform : ' + os.platform());
 
// 系统内存总量
console.log('total memory : ' + os.totalmem() + " bytes.");
 
// 操作系统空闲内存量
console.log('free memory : ' + os.freemem() + " bytes.");
 
//获得网络接口列表
console.log(os.networkInterfaces());

  ip = "",
  ifaces = os.networkInterfaces(); // 获取本机ip
out: for (var i in ifaces) {
  for (var j in ifaces[i]) {
    var val = ifaces[i][j];
    if (val.family === "IPv4" && val.address !== "127.0.0.1") {
      ip = val.address;
      break out;
    }
  }
}
module.exports = ip;
