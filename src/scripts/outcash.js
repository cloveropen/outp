// import context from "../main.js";
// ----------查询门诊号对应患者挂号信息----------------------------------------------------------
export async function get_reg4cash(tpid, topcode, tgc) {
  let toutreg = Array.of(); //挂号患者信息串
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchoutregcash/" +
    tpid +
    "/" +
    thsp_code +
    "/" +
    topcode +
    "/" +
    tgc;
  await fetch_cash_async(turl, "get").then(data => {
    toutreg = JSON.stringify(data);
    return toutreg;
  });
  return toutreg;
}

//-------------查询门诊号对应患者待交款信息----------------------------------------------------------
export async function get_feedetail4cash(tpid, topcode, tgc) {
  let tfees = Array.of(); //挂号患者信息串
  let thsp_code = process.env.VUE_APP_HSP_CODE;
  let turl =
    process.env.VUE_APP_REG_URL +
    "/searchfeedetail/" +
    tpid +
    "/9/" +
    thsp_code +
    "/" +
    topcode +
    "/" +
    tgc;
  await fetch_cash_async(turl, "get").then(data => {
    tfees = JSON.stringify(data);
    return tfees;
  });
  return tfees;
}
//--------------------------查询操作员编号--------------------------------------------------------
export function get_regopcode() {
  let user = JSON.parse(localStorage.getItem("user"));
  if (!user) {
    return this.$parent.$router.push({ path: "/login" });
  }
  return user.opid + "|" + user.tgc;
}

//---公用后台获取数据接口--------------------------------------
async function fetch_cash_async(turl, tmethod) {
  try {
    let response = await fetch(turl, {
      method: tmethod,
      headers: {
        Accept: "text/html",
        "Content-Type": "application/json"
      }
    });
    return await response.json();
  } catch (err) {
    console.error(err);
    // Handle errors here
  }
}
