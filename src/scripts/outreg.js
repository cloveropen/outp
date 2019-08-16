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
  return patient_types;
}

//--------------------------查询操作员编号--------------------------------------------------------
export function get_regopcode() {
  let user = JSON.parse(localStorage.getItem("user"));
  if (!user) {
    return this.$parent.$router.push({ path: "/login" });
  }
  //this.out_reg.regOpcode = user.opid;
  console.log("regopid=" + user.opid);
  return user.opid;
}
// -------------------------------------------------------------------------------------------------------------------------------------------
//export default {
//    getpatient_type
//};
