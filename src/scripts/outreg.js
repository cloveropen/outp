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
        // console.log(patient_types.toString());
        return patient_types;
      } else {
        //登录失败
        window.alert("获取患者类别查询失败1");
        return patient_types;
      }
    })
    .catch(function(err) {
      window.alert("获取患者类别查询error=" + err);
      return patient_types;
    });
  console.log("patient_types===="+patient_types)
  return patient_types;
}

//---------------------------------------获取性别列表----------------------------------------------
export function getgender() {
  let genders = Array.of(); //性别列表
  console.log("1111")
  let data = fetch_data_api(process.env.VUE_APP_REG_URL + "/searchdicthealthterm/gender_type", "get")
  console.log("2222:"+JSON.stringify(data))
  
  for (let i = 0; i < data.length; i++) {
      genders.splice(i, 0, {
      "item-value": data[i].TermId,
      "item-text": data[i].TermName
      });
  }
  return genders;
}

//--------------------------查询操作员编号--------------------------------------------------------
export function get_regopcode() {
  let user = JSON.parse(localStorage.getItem("user"));
  if (!user) {
    return this.$parent.$router.push({ path: "/login" });
  }
  console.log("regopid=" + user.opid);
  return user.opid;
}

// -------------------------------------------------------------------------------------------------------------------------------------------

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
      console.log("data1="+JSON.stringify(ret_data));
      return ret_data;
    })
    .catch(function(err) {
      window.alert("获取患者类别查询error=" + err);
      return err;
    });
    //console.log("ret_data="+JSON.stringify(ret_data));
     //return ret_data;
}
