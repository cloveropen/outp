//-------------------------获取患者类别-----------------------------------------------------------
export function getpatient_type() {
  let patient_types = Array.of(); //患者类别列表
  fetch(process.env.VUE_APP_REG_URL + "/searchdicthealthterm/per_cate", {
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
        window.alert("获取患者类别查询失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          patient_types.splice(i, 0, {
            "item-value": objdata[i].termId,
            "item-text": objdata[i].termName
          });
        }
        return patient_types;
      } else {
        //登录失败
        window.alert("获取患者类别查询失败1" + data.errorMsg);
        return patient_types;
      }
    })
    .catch(function(err) {
      window.alert("获取患者类别查询error=" + err);
      return patient_types;
    });
  return patient_types;
}

//---------------------------------------获取性别列表----------------------------------------------
export function getgender() {
  let genders = Array.of(); //性别列表
  fetch(process.env.VUE_APP_REG_URL + "/searchdicthealthterm/gender_type", {
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
        window.alert("获取患者性别查询失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          genders.splice(i, 0, {
            "item-value": objdata[i].termId,
            "item-text": objdata[i].termName
          });
        }
        return genders;
      } else {
        window.alert("获取患者性别查询失败1" + data.errorMsg);
        return genders;
      }
    })
    .catch(function(err) {
      window.alert("获取患者性别查询error=" + err);
      return genders;
    });
  return genders;
}

//---------------------------查询身份证件类型列表--------------------------------------------------
export function getid_type() {
  let idcard_types = Array.of(); //身份证件类型
  fetch(process.env.VUE_APP_REG_URL + "/searchdicthealthterm/id_type", {
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
        window.alert("获取身份证件类型失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          idcard_types.splice(i, 0, {
            "item-value": objdata[i].termId,
            "item-text": objdata[i].termName
          });
        }
        return idcard_types;
      } else {
        window.alert("获取身份证件类型失败1" + data.errorMsg);
        return idcard_types;
      }
    })
    .catch(function(err) {
      window.alert("获取患者性别查询error=" + err);
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
  return user.opid;
}

//----------------------------查询挂号类别列表------------------------------------------------------
export function getreg_type() {
  let reg_types = Array.of(); //挂号类别
  fetch(process.env.VUE_APP_REG_URL + "/searchdictregitem/0", {
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
        window.alert("获取挂号类别失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          reg_types.splice(i, 0, {
            "item-value": objdata[i].itemCode,
            "item-text": objdata[i].itemName
          });
        }
        return reg_types;
      } else {
        window.alert("获取挂号类别失败1" + data.errorMsg);
        return reg_types;
      }
    })
    .catch(function(err) {
      window.alert("获取挂号类别查询error=" + err);
      return reg_types;
    });
  return reg_types;
}

//----------------------------查询指定挂号类别的挂号费------------------------------------------------------
export async function getregprice(treg_type) {
  let treg_price = Array.of();
  //let treg_price = 0.0;
  //let tchk_price = 0.0;
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
        /*for (let i = 0; i < objdata.length; i++) {
          treg_price.splice(i, 0, {
            regprice: objdata[i].refPrice,
            chkprice: objdata[i].realPrice
          });
        }*/
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
  fetch(process.env.VUE_APP_REG_URL + "/searchdictdepartment/clinical", {
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
        window.alert("获取科室列表失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          dept_codes.splice(i, 0, {
            "item-value": objdata[i].deptCode,
            "item-text": objdata[i].deptName
          });
        }
        return dept_codes;
      } else {
        window.alert("获取科室列表失败1" + data.errorMsg);
        return dept_codes;
      }
    })
    .catch(function(err) {
      window.alert("获取科室列表查询error=" + err);
      return dept_codes;
    });
  return dept_codes;
}

//----------------------------------------查询本科室可以挂号的专家列表---------------------------------------------------
export function getdoctor_codes(tdept_code, tpost_tech) {
  let doctor_codes = Array.of(); //专家列表
  console.log(
    "url=" +
      process.env.VUE_APP_REG_URL +
      "/searchdictpersonreg/" +
      tdept_code +
      "/" +
      tpost_tech
  );
  fetch(
    process.env.VUE_APP_REG_URL +
      "/searchdictpersonreg/" +
      tdept_code +
      "/" +
      tpost_tech,
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
        window.alert(
          "获取本科室可以挂号的专家列表失败error" + response.statusText
        );
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          doctor_codes.splice(i, 0, {
            "item-value": objdata[i].personId,
            "item-text": objdata[i].personName
          });
        }
        return doctor_codes;
      } else {
        window.alert("获取本科室可以挂号的专家列表1" + data.errorMsg);
        return doctor_codes;
      }
    })
    .catch(function(err) {
      window.alert("获取本科室可以挂号的专家列表失败=" + err);
      return doctor_codes;
    });
  return doctor_codes;
}

//------------------获取省份列表---------------------------
export function getprovs() {
  let addr_provs = Array.of(); //患者类别列表
  fetch(process.env.VUE_APP_REG_URL + "/searchdictprov", {
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
        window.alert("获取省份列表查询失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          addr_provs.splice(i, 0, {
            "item-value": objdata[i].provinceId,
            "item-text": objdata[i].name
          });
        }
        return addr_provs;
      } else {
        //登录失败
        window.alert("获取省份列表失败1" + data.errorMsg);
        return addr_provs;
      }
    })
    .catch(function(err) {
      window.alert("获取省份列表查询error=" + err);
      return addr_provs;
    });
  return addr_provs;
}

//------------------获取指定省份的市列表---------------------------
export function getcitys(tprovid) {
  let addr_citys = Array.of(); //市列表
  fetch(process.env.VUE_APP_REG_URL + "/searchdictcity/" + tprovid, {
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
        window.alert("获取指定省份的市列表失败error" + response.statusText);
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          addr_citys.splice(i, 0, {
            "item-value": objdata[i].cityId,
            "item-text": objdata[i].name
          });
        }
        return addr_citys;
      } else {
        window.alert("获取指定省份的市列表1" + data.errorMsg);
        return addr_citys;
      }
    })
    .catch(function(err) {
      window.alert("获取指定省份的市列表失败=" + err);
      return addr_citys;
    });
  return addr_citys;
}

//------------------获取指定市的区县列表---------------------------
export function getcountys(tcityid) {
  let addr_countys = Array.of(); //指定市的区县列表
  fetch(process.env.VUE_APP_REG_URL + "/searchdictcounty/" + tcityid, {
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
        window.alert("获取指定市的区县列表失败error" + response.statusText);
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          addr_countys.splice(i, 0, {
            "item-value": objdata[i].countryId,
            "item-text": objdata[i].name
          });
        }
        return addr_countys;
      } else {
        window.alert("获取指定市的区县列表列表1" + data.errorMsg);
        return addr_countys;
      }
    })
    .catch(function(err) {
      window.alert("获取指定市的区县列表失败=" + err);
      return addr_countys;
    });
  return addr_countys;
}

//------------------获取指定区县的街道列表---------------------------
export function getstreets(tcountyid) {
  let addr_townships = Array.of(); //指定区县的街道列表
  fetch(process.env.VUE_APP_REG_URL + "/searchdictstreet/" + tcountyid, {
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
        window.alert("获取指定区县的街道列表失败error" + response.statusText);
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        let objdata = JSON.parse(data.outdata);
        for (let i = 0; i < objdata.length; i++) {
          addr_townships.splice(i, 0, {
            "item-value": objdata[i].townId,
            "item-text": objdata[i].name
          });
        }
        return addr_townships;
      } else {
        window.alert("获取指定区县的街道列表1" + data.errorMsg);
        return addr_townships;
      }
    })
    .catch(function(err) {
      window.alert("获取指定区县的街道列表失败=" + err);
      return addr_townships;
    });
  return addr_townships;
}
//----------------------医保读卡------------------------------------------------------------------
export function readcard_mi() {
  // this.$refs.form.resetValidation();
  window.alert("医保读卡");
  return "医保读卡";
}
//-----------------------------根据条码号获取患者信息查询-----------------------------------
export function getpatient(texpid) {
  let toutreg = {};
  console.log(
    "url=" + process.env.VUE_APP_REG_URL + "/searchoutregexpid/" + texpid
  );
  fetch(process.env.VUE_APP_REG_URL + "/searchoutregexpid/" + texpid, {
    method: "get",
    headers: {
      Accept: "text/html",
      "Content-Type": "application/json"
    }
  })
    .then(function(response) {
      if (response.ok) {
        //window.alert('ok');
      } else {
        window.alert("根据条码号获取患者信息查询失败error");
      }
      return response.json();
    })
    .then(function(data) {
      let tresultCode = data.resultCode;
      if (tresultCode === "0") {
        toutreg = JSON.parse(data.outdata);
        return toutreg;
      } else {
        //登录失败
        window.alert("根据条码号获取患者信息查询失败1");
      }
    })
    .catch(function(err) {
      window.alert("根据条码号获取患者信息查询error=" + err);
    });
  return toutreg;
}

//------------------------确认现金挂号------------------------------------------------------------
export function outreg_cash(tout_reg) {
  console.log("JSON.stringify(tout_reg)=" + JSON.stringify(tout_reg));
  fetch(process.env.VUE_APP_REG_URL + "/saveoutreg", {
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
      console.log("data1=" + data.outdata + "|" + data.outdata.length);
      let tresultCode = data.resultCode;
      window.alert("tresultCode=" + tresultCode);
      if (tresultCode === "0") {
        //现金挂号按钮disable
        window.alert("现金挂号完成");
        //打印挂号单
      } else {
        //登录失败
        window.alert("确认现金挂号失败1");
      }
    })
    .catch(function(err) {
      window.alert("确认现金挂号error=" + err);
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
/*
function fetch_data_api(turl, tmethod) {
  let ret_data ;
  console.log("turl="+turl+" tmethod="+tmethod)
  fetch(turl, {
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
        window.alert("查询性别失败:"+data.errorMsg);
      }
      console.log("性别data1="+JSON.stringify(ret_data));
      return ret_data;
    })
    .catch(function(err) {
      window.alert("获取患者类别查询error=" + err);
      return err;
    });
    //console.log("ret_data="+JSON.stringify(ret_data));
     //return ret_data;
}


export const request = (url, config) => {
  return fetch(url, config).then((res) => {
    if (res.ok) {
      console.log("res status="+res.statusText)
      return res.json()
    } else {
      // 服务器异常
      console.log("服务器异常"+res.statusText)
      throw Error('')
    }
  }).then((resJson) => {
    console.log("resJson"+JSON.stringify(resJson))
    return resJson
  }).catch((error) => {
      window.alert('errorMessage')
  })
}

export const get = (url) => {
  return request(url, { method: 'GET' })
}

export const post = (url, config) => {
  return request(url, {
    method: 'POST',
    headers: {
      'content-type': 'application/json'
    },
    body: JSON.stringify(config)
  })
}
*/
