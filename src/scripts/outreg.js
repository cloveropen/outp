//-------------------------获取患者类别-----------------------------------------------------------
export function getpatient_type() {
  let patient_types = Array.of(); //患者类别列表
  let tstr = get_regopcode(); //登录成功票据
  let tstr_s = tstr.split("|");
  let topcode = tstr_s[0];
  let tgc = tstr_s[1];
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
export function getgender() {
  let genders = Array.of(); //性别列表
  let turl = process.env.VUE_APP_REG_URL + "/searchdicthealthterm/gender_type";
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
export function getid_type() {
  let idcard_types = Array.of(); //身份证件类型
  let turl = process.env.VUE_APP_REG_URL + "/searchdicthealthterm/id_type";
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
export function getreg_type() {
  let reg_types = Array.of(); //挂号类别
  let turl = process.env.VUE_APP_REG_URL + "/searchdictregitem/0";
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
export async function getregprice(treg_type) {
  let treg_price = Array.of();
  await fetch(
    process.env.VUE_APP_REG_URL + "/searchdictregitemprice/" + treg_type,
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
export function getdept_codes() {
  let dept_codes = Array.of(); //科室列表
  let turl = process.env.VUE_APP_REG_URL + "/searchdictdepartment/clinical";
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
export function getdoctor_codes(tdept_code, tpost_tech) {
  let doctor_codes = Array.of(); //专家列表
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchdictpersonreg/" +
    tdept_code +
    "/" +
    tpost_tech;
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
export function getprovs() {
  let addr_provs = Array.of(); //患者类别列表
  let turl = process.env.VUE_APP_REG_URL + "/searchdictprov";
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
export function getcitys(tprovid) {
  let addr_citys = Array.of(); //市列表
  let turl = process.env.VUE_APP_REG_URL + "/searchdictcity/" + tprovid;
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
export function getcountys(tcityid) {
  let addr_countys = Array.of(); //指定市的区县列表
  let turl = process.env.VUE_APP_REG_URL + "/searchdictcounty/" + tcityid;
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
export function getstreets(tcountyid) {
  let addr_townships = Array.of(); //指定区县的街道列表
  let turl = process.env.VUE_APP_REG_URL + "/searchdictstreet/" + tcountyid;
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
export async function getpatient(texpid) {
  let toutreg = {};
  await fetch(process.env.VUE_APP_REG_URL + "/searchoutregexpid/" + texpid, {
    method: "get",
    headers: {
      Accept: "text/html",
      "Content-Type": "application/json"
    }
  })
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
export async function outreg_cash(tout_reg) {
  let tpid = "";
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
export function outreg_pic(tout_reg_pic) {
  //console.log("JSON.stringify(tout_reg_pic)=" + JSON.stringify(tout_reg_pic));
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
        window.alert("查询失败:" + data.errorMsg);
      }
      return ret_data;
    })
    .catch(function(err) {
      console.log("查询error=" + err);
      window.alert("查询error=" + err);
      return err;
    });
  //console.log("ret_data="+JSON.stringify(ret_data));
  return await ret_data;
}
