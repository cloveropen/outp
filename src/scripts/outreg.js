import context from "../main.js";
//-------------------------获取患者类别-----------------------------------------------------------
export function getpatient_type(topcode, tgc) {
  let patient_types = Array.of(); //患者类别列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdicthealthterm/per_cate/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      patient_types.splice(i, 0, {
        "item-value": data[i].termId,
        "item-text": data[i].termName
      });
    }
    return patient_types;
  });
  return patient_types;
}

//---------------------------------------获取性别列表----------------------------------------------
export function getgender(topcode, tgc) {
  let genders = Array.of(); //性别列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdicthealthterm/gender_type/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      genders.splice(i, 0, {
        "item-value": data[i].termId,
        "item-text": data[i].termName
      });
    }
    return genders;
  });
  return genders;
}

//---------------------------查询身份证件类型列表--------------------------------------------------
export function getid_type(topcode, tgc) {
  let idcard_types = Array.of(); //身份证件类型
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdicthealthterm/id_type/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      idcard_types.splice(i, 0, {
        "item-value": data[i].termId,
        "item-text": data[i].termName
      });
    }
    return idcard_types;
  });
  return idcard_types;
}

//--------------------------查询操作员编号--------------------------------------------------------
export function get_regopcode() {
  let user = JSON.parse(localStorage.getItem("user"));
  if (!user) {
    return this.$parent.$router.push({ path: "/login" });
  }
  return user.opid + "|" + user.tgc;
}

//----------------------------查询挂号类别列表------------------------------------------------------
export function getreg_type(topcode, tgc) {
  let reg_types = Array.of(); //挂号类别
  let turl =
    process.env.VUE_APP_REG_URL + "/searchdictregitem/0/" + topcode + "/" + tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      reg_types.splice(i, 0, {
        "item-value": data[i].itemCode,
        "item-text": data[i].itemName
      });
    }
    return reg_types;
  });
  return reg_types;
}

//----------------------------查询指定挂号类别的挂号费------------------------------------------------------
export async function getregprice(treg_type, topcode, tgc) {
  let treg_price = Array.of();
  await fetch(
    process.env.VUE_APP_REG_URL +
      "/searchdictregitemprice/" +
      treg_type +
      "/" +
      topcode +
      "/" +
      tgc,
    {
      method: "get",
      headers: {
        Accept: "text/html",
        "Content-Type": "application/json"
      }
    }
  )
    .then(function(response) {
      if (response.ok) {
        // window.alert("---ok=");
      } else {
        window.alert("获取指定挂号类别的挂号费失败error" + response.text);
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        treg_price = [objdata[0].refPrice, objdata[0].realPrice];
        console.log("treg_price=" + JSON.stringify(treg_price));
        //return treg_price;
      } else {
        window.alert("获取指定挂号类别的挂号费失败1" + data.errorMsg);
        return treg_price;
      }
    })
    .catch(function(err) {
      window.alert("获取指定挂号类别的挂号费查询error=" + err);
      return treg_price;
    });
  return treg_price;
}

//-------------------------------------查询科室列表------------------------------------------------------
export function getdept_codes(topcode, tgc) {
  let dept_codes = Array.of(); //科室列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdictdepartment/clinical/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      dept_codes.splice(i, 0, {
        "item-value": data[i].deptCode,
        "item-text": data[i].deptName
      });
    }
    return dept_codes;
  });
  return dept_codes;
}

//----------------------------------------查询本科室可以挂号的专家列表---------------------------------------------------
export function getdoctor_codes(tdept_code, tpost_tech, topcode, tgc) {
  let doctor_codes = Array.of(); //专家列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdictpersonreg/" +
    tdept_code +
    "/" +
    tpost_tech +
    "/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      doctor_codes.splice(i, 0, {
        "item-value": data[i].personId,
        "item-text": data[i].personName
      });
    }
    return doctor_codes;
  });
  return doctor_codes;
}

//------------------获取省份列表---------------------------
export function getprovs(topcode, tgc) {
  let addr_provs = Array.of(); //患者类别列表
  let turl =
    process.env.VUE_APP_REG_URL + "/searchdictprov/" + topcode + "/" + tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      addr_provs.splice(i, 0, {
        "item-value": data[i].provinceId,
        "item-text": data[i].name
      });
    }
    return addr_provs;
  });
  return addr_provs;
}

//------------------获取指定省份的市列表---------------------------
export function getcitys(tprovid, topcode, tgc) {
  let addr_citys = Array.of(); //市列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdictcity/" +
    tprovid +
    "/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      addr_citys.splice(i, 0, {
        "item-value": data[i].cityId,
        "item-text": data[i].name
      });
    }
    return addr_citys;
  });
  return addr_citys;
}

//------------------获取指定市的区县列表---------------------------
export function getcountys(tcityid, topcode, tgc) {
  let addr_countys = Array.of(); //指定市的区县列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdictcounty/" +
    tcityid +
    "/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      addr_countys.splice(i, 0, {
        "item-value": data[i].countryId,
        "item-text": data[i].name
      });
    }
    return addr_countys;
  });
  return addr_countys;
}

//------------------获取指定区县的街道列表---------------------------
export function getstreets(tcountyid, topcode, tgc) {
  let addr_townships = Array.of(); //指定区县的街道列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdictstreet/" +
    tcountyid +
    "/" +
    topcode +
    "/" +
    tgc;
  fetch_data_api(turl, "get").then(data => {
    for (let i = 0; i < data.length; i++) {
      addr_townships.splice(i, 0, {
        "item-value": data[i].townId,
        "item-text": data[i].name
      });
    }
    return addr_townships;
  });
  return addr_townships;
}

//----------------------医保读卡------------------------------------------------------------------
export async function readcard_mi() {
  // this.$refs.form.resetValidation();VUE_APP_MI_URL
  // 如果没有做动态库初始化则先调用动态库初始化接口,做签到操作,成功后返回业务周期号
  window.alert("医保读卡");
  return "医保读卡";
}

//----------------------------查询患者主索引信息------------------------------------------------------
export async function getpatient(texpid, topcode, tgc) {
  let toutreg = {};
  await fetch(
    process.env.VUE_APP_REG_URL +
      "/searchoutregexpid/" +
      texpid +
      "/" +
      topcode +
      "/" +
      tgc,
    {
      method: "get",
      headers: {
        Accept: "text/html",
        "Content-Type": "application/json"
      }
    }
  )
    .then(function(response) {
      if (response.ok) {
        // window.alert("---ok=");
      } else {
        window.alert("查询患者主索引信息失败error" + response.text);
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        toutreg = JSON.parse(data.outdata);
        //console.log("toutreg=" + JSON.stringify(toutreg));
        //return toutreg;
      } else {
        window.alert("查询患者主索引信息失败1" + data.errorMsg);
        return toutreg;
      }
    })
    .catch(function(err) {
      window.alert("查询患者主索引信息查询error=" + err);
      return toutreg;
    });
  return toutreg;
}

//------------------------确认现金挂号------------------------------------------------------------
export async function outreg_cash(tout_reg, topcode, tgc) {
  let tpid = "";
  tout_reg.topcode = topcode;
  tout_reg.tgc = tgc;
  console.log("JSON.stringify(tout_reg)=" + JSON.stringify(tout_reg));
  await fetch(process.env.VUE_APP_REG_URL + "/saveoutreg", {
    method: "post",
    // credentials: "include", // send cookies
    // mode: 'cors',
    body: JSON.stringify(tout_reg),
    headers: {
      Accept: "application/json, text/plain, */*",
      "Content-Type": "application/json"
    }
  })
    .then(function(response) {
      if (response.ok) {
        //window.alert('ok');
      } else {
        window.alert("确认现金挂号查询失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        //现金挂号按钮disable
        //window.alert("现金挂号完成" + data.outdata);
        tpid = data.outdata;
        //打印挂号单
      } else {
        //登录失败
        window.alert("确认现金挂号失败1");
      }
    })
    .catch(function(err) {
      window.alert("确认现金挂号error=" + err);
    });
  return await tpid;
}

//------------------------上传挂号照片------------------------------------------------------------
export function outreg_pic(tout_reg_pic, topcode, tgc) {
  //console.log("JSON.stringify(tout_reg_pic)=" + JSON.stringify(tout_reg_pic));
  tout_reg_pic.topcode = topcode;
  tout_reg_pic.tgc = tgc;
  fetch(process.env.VUE_APP_REG_URL + "/saveoutregpic", {
    method: "post",
    body: JSON.stringify(tout_reg_pic),
    headers: {
      Accept: "application/json, text/plain, */*",
      "Content-Type": "application/json"
    }
  })
    .then(function(response) {
      if (response.ok) {
        //window.alert('ok');
      } else {
        window.alert("上传挂号照片失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        //现金挂号按钮disable
        window.alert("上传挂号照片完成" + data.outdata);
        //打印挂号单
      } else {
        //登录失败
        window.alert("上传挂号照片失败1");
      }
    })
    .catch(function(err) {
      window.alert("上传挂号照片error=" + err);
    });
  return "";
}
//------------------------确认微信挂号------------------------------------------------------------
export function outreg_weixin() {
  //console.log(this.$refs.form.data);
  console.log("确认微信挂号");
  return "";
}
//-------------------------查询微信订单-----------------------------------------------------------
export function sch_weixin() {
  // console.log(this.$refs.form.data);
  console.log("查询微信订单");
  return "";
}

// -------------------------------------------------------------------------------------------------------------------------------------------
//---公用后台获取数据接口---------------------------------------
async function fetch_data_api(turl, tmethod) {
  let ret_data;
  await fetch(turl, {
    method: tmethod,
    headers: {
      Accept: "text/html",
      "Content-Type": "application/json"
    }
  })
    .then(function(response) {
      if (response.ok) {
        // window.alert("---ok=");
      } else {
        window.alert("警告:" + turl + "查询失败:" + response.statusText);
      }
      return response.json();
    })
    .then(function(data) {
      ret_data = data;
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        ret_data = JSON.parse(data.outdata);
      } else {
        //返回失败数据
        console.log("查询失败:" + data.errorMsg);
        // window.alert("查询失败:" + data.errorMsg);
        context.$router.push({ path: "/login" });
        return "";
      }
      return ret_data;
    })
    .catch(function(err) {
      console.log("查询error=" + err);
      window.alert("查询error=" + err);
      context.$router.push({ path: "/login" });
      return err;
    });
  //console.log("ret_data="+JSON.stringify(ret_data));
  return await ret_data;
}
