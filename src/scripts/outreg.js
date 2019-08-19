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
            "item-value": objdata[i].TermId,
            "item-text": objdata[i].TermName
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
            "item-value": objdata[i].TermId,
            "item-text": objdata[i].TermName
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
            "item-value": objdata[i].TermId,
            "item-text": objdata[i].TermName
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
  fetch(process.env.VUE_APP_REG_URL + "/searchdictregitem", {
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
            "item-value": objdata[i].ItemCode,
            "item-text": objdata[i].ItemName
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
