<template>
  <v-form ref="form" v-model="valid" lazy-validation>
    <v-layout row wrap>
      <v-flex d-flex>
        <v-text-field
          v-model="out_reg.exPid"
          label="条码号"
          required
          :counter="13"
          :rules="barcodeRules"
          @input="getpatient($event)"
        ></v-text-field>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.patientType"
          label="患者类别"
          required
          :items="patient_types"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '患者类别不能为空']"
          hide-details
          prepend-icon="map"
          single-line
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-text-field
          v-model="out_reg.patientName"
          label="患者姓名"
          required
          :counter="6"
          :rules="nameRules"
        ></v-text-field>
      </v-flex>
      <v-flex d-flex>
        <v-text-field
          v-model="out_reg.idcard"
          label="身份证号"
          disabled
        ></v-text-field>
      </v-flex>
    </v-layout>
    <v-layout row wrap>
      <v-flex d-flex>
        <v-text-field
          v-model="out_reg.pid"
          label="门诊号"
          disabled
        ></v-text-field>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.gender"
          :items="genders"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '患者性别不能为空']"
          label="性别"
          hide-details
          prepend-icon="map"
          single-line
          required
        ></v-select>
      </v-flex>
      <v-flex>
        <v-layout row wrap>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.ageY"
              label="年龄(岁)"
            ></v-text-field>
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.ageM"
              label="年龄(月)"
            ></v-text-field>
          </v-flex>
          <v-flex d-flex>
            <v-text-field
              v-model="out_reg.ageD"
              label="年龄(天)"
            ></v-text-field>
          </v-flex>
        </v-layout>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.idcardType"
          :items="idcard_types"
          item-text="item-text"
          item-value="item-value"
          label="证件类型"
          hide-details
          prepend-icon="map"
          single-line
        ></v-select>
      </v-flex>
    </v-layout>

    <v-layout row wrap>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.regType"
          label="挂号类别"
          required
          :items="reg_types"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '挂号类别不能为空']"
          hide-details
          prepend-icon="map"
          single-line
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.deptCode"
          :items="dept_codes"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '就诊科室不能为空']"
          label="就诊科室"
          hide-details
          prepend-icon="group_work"
          single-line
          required
          @input="dept_codeChanged"
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.doctorCode"
          :items="doctor_codes"
          item-text="item-text"
          item-value="item-value"
          label="专家医师"
          hide-details
          prepend-icon="map"
          single-line
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-switch v-model="out_reg.visitPriority" label="就诊优先"></v-switch>
      </v-flex>
    </v-layout>
    <v-layout row wrap>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.addrProv"
          :items="addr_provs"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '单位或住址省份不能为空']"
          label="单位或住址(省份)"
          hide-details
          prepend-icon="group_work"
          single-line
          required
          @input="prov_Changed"
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.addrCity"
          :items="addr_citys"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '单位或住址-市不能为空']"
          label="单位或住址(市)"
          hide-details
          prepend-icon="group_work"
          single-line
          required
          @input="city_Changed"
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.addrCounty"
          :items="addr_countys"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '单位或住址-区县不能为空']"
          label="单位或住址(区县)"
          hide-details
          prepend-icon="group_work"
          single-line
          required
          @input="county_Changed"
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-select
          v-model="out_reg.addrTownship"
          :items="addr_townships"
          item-text="item-text"
          item-value="item-value"
          :rules="[v => !!v || '单位或住址-街道社区不能为空']"
          label="单位或住址(街道社区)"
          hide-details
          prepend-icon="group_work"
          single-line
          required
        ></v-select>
      </v-flex>
      <v-flex d-flex>
        <v-text-field
          v-model="out_reg.addrHouseNmb"
          label="单位或住址(详细地址)"
        ></v-text-field>
      </v-flex>
    </v-layout>
    <v-spacer>----</v-spacer>
    <v-layout row wrap>
      <v-flex xs12>
        <v-card color="cyan darken-2" class="white--text">
          <v-card-title primary-title>
            <div>
              <div class="headline">
                挂号费合计:&nbsp;&nbsp;{{
                  out_reg.regPrice + out_reg.CheckupPrice
                }}
              </div>
              <v-layout row align-center wrap>
                <v-flex d-flex grow>其中</v-flex>
                <v-flex d-flex
                  >挂号费:&nbsp;&nbsp;{{ out_reg.regPrice }}</v-flex
                >
                <v-flex d-flex
                  >诊察费:&nbsp;&nbsp;{{ out_reg.CheckupPrice }}</v-flex
                >
              </v-layout>
            </div>
          </v-card-title>
        </v-card>
      </v-flex>
    </v-layout>

    <v-card>
      <v-container fluid grid-list-lg>
        <v-layout row wrap>
          <v-flex xs12>
            <v-card color="cyan darken-2" class="white--text">
              <v-card-title primary-title>
                <div>
                  <div class="headline">医保患者信息</div>
                  <v-layout row wrap>
                    <v-flex d-flex>医保个人编号:{{ out_reg.micard }}</v-flex>
                    <v-flex d-flex>医保卡余额:{{ out_reg.miPaccLeft }}</v-flex>
                    <v-flex d-flex>医保类别:{{ out_reg.miType }}</v-flex>
                    <v-flex d-flex>参保单位:{{ out_reg.miCompany }}</v-flex>
                    <v-flex d-flex grow>读卡信息:{{ out_reg.miStr }}</v-flex>
                  </v-layout>
                </div>
              </v-card-title>
            </v-card>
          </v-flex>
        </v-layout>
      </v-container>
    </v-card>

    <v-layout row wrap>
      <v-flex d-flex>
        <v-btn :disabled="!valid" color="success" @click="validate"
          >健康卡</v-btn
        >
      </v-flex>
      <v-flex d-flex>
        <v-btn :disabled="!valid" color="success" @click="readcard_mi"
          >医保读卡</v-btn
        >
      </v-flex>
      <v-flex d-flex>
        <v-btn :disabled="!valid" color="success" @click="outreg_cash"
          >现金挂号</v-btn
        >
      </v-flex>
      <v-flex d-flex>
        <v-btn :disabled="!valid" color="success" @click="outreg_weixin"
          >微信挂号</v-btn
        >
      </v-flex>
      <v-flex d-flex>
        <v-btn :disabled="!valid" color="success" @click="sch_weixin"
          >查询微信订单</v-btn
        >
      </v-flex>
      <v-flex d-flex>
        <v-btn color="error" @click="reset">下一位</v-btn>
      </v-flex>
      <v-flex d-flex>
        <v-btn color="warning" @click="resetValidation">返回主页</v-btn>
      </v-flex>
    </v-layout>
  </v-form>
</template>

<script>
export default {
  data: () => ({
    valid: true,
    nameRules: [
      v => !!v || "姓名不能为空",
      v => (v && v.length >= 2) || "姓名长度不能少于2个汉字"
    ],
    barcodeRules: [
      v => !!v || "条形码不能为空",
      v => (v && v.length >= 13) || "条形码应该为13位数字"
    ],
    patient_types: [], //患者类别列表
    genders: [], //性别列表
    idcard_types: [], //身份证件类型列表
    dept_codes: [], //就诊科室列表
    doctor_codes: [], //专家号专家列表
    reg_types: [], //挂号类别
    addr_provs: [], //单位或住址(省份)
    addr_citys: [], //单位或住址(市)
    addr_countys: [], //单位或住址(区县)
    addr_townships: [], //单位或住址(街道)
    out_reg: {
      pid: "", //门诊号
      pidType: "O", //患者标识类别
      exPid: "", //条形码
      patientName: "", //患者姓名
      gender: "", //性别代码
      ageY: "", // 年龄
      ageM: "", //  年龄
      ageD: "", //  年龄
      patientType: "", //患者类型
      regType: "pz", // 挂号类别
      regPrice: 0.0, //挂号费
      CheckupPrice: 0.0, //诊察费
      visitPriority: "0", //就诊优先标志
      deptCode: "", //就诊科室
      doctorCode: "", //门诊接诊医生
      idcard: "", //患者身份证号码
      idcardType: "jmsfz", //患者身份证件类别
      addrProv: "210000000000", //地址
      addrCity: "210100000000",
      addrCounty: "210105000000",
      addrTownship: "",
      addrStreet: "",
      addrHouseNmb: "",
      miPaccLeft: 0,
      miCompany: "",
      miStr: "",
      miType: "",
      micard: "",
      payType: "",
      deptRegNmb: "",
      doctorRegNmb: "",
      regOpcode: "" //挂号员
    }
  }),
  created() {
    this.get_regopcode();
    this.getpatient_type();
    this.getgender();
    this.getid_type();
    this.getreg_type();
    this.getdept_codes();
    this.getprovs();
    //console.log("this.patient_type[0]=" + this.patient_types[0]);
  },
  methods: {
    validate() {
      if (this.$refs.form.validate()) {
        this.snackbar = true;
      }
    },
    reset() {
      this.$refs.form.reset();
    },
    resetValidation() {
      this.$refs.form.resetValidation();
    },
    //----------------------医保读卡------------------------------------------------------------------
    readcard_mi() {
      this.$refs.form.resetValidation();
      window.alert("医保读卡");
    },
    //------------------------确认现金挂号------------------------------------------------------------
    outreg_cash() {
      let _this = this;
      console.log(
        "JSON.stringify(this.out_reg)=" + JSON.stringify(this.out_reg)
      );
      fetch("http://192.168.100.253:9002/api/v1/saveoutreg", {
        method: "post",
        // credentials: "include", // send cookies
        // mode: 'cors',
        body: JSON.stringify(this.out_reg),
        headers: {
          Accept: "application/json, text/plain, */*",
          "Content-Type": "application/json"
        }
      })
        .then(function(response) {
          if (response.ok) {
            //window.alert('ok');
          } else {
            window.alert("查询失败error");
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
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //------------------------确认微信挂号------------------------------------------------------------
    outreg_weixin() {
      console.log(this.$refs.form.data);
    },
    //-------------------------查询微信订单-----------------------------------------------------------
    sch_weixin() {
      console.log(this.$refs.form.data);
    },
    //--------------------------查询操作员编号--------------------------------------------------------
    get_regopcode() {
      let user = JSON.parse(localStorage.getItem("user"));
      if (!user) {
        return this.$parent.$router.push({ path: "/login" });
      }
      this.out_reg.regOpcode = user.opid;
      console.log("regopid=" + user.opid);
    },
    //--------------------------根据条码号获取患者信息------------------------------------------------
    getpatient(e) {
      let texpid = e;
      if (texpid.length < 13) {
        return;
      }
      let _this = this;
      fetch("http://192.168.100.253:9002/api/v1/searchoutregexpid/" + texpid, {
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
            window.alert("查询失败error");
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let toutreg = JSON.parse(data.outdata);
            _this.out_reg = toutreg;
            _this.get_regopcode();
            // console.log("sel.patient_types[i]=" + _this.patient_types);
            return _this.out_reg;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //-------------------------获取患者类别-----------------------------------------------------------
    getpatient_type() {
      let _this = this;
      fetch(
        "http://192.168.100.253:9002/api/v1/searchdicthealthterm/per_cate",
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
            //window.alert('ok');
          } else {
            window.alert("查询失败error");
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            //console.log("data1=" + data.outdata+"|"+data.outdata.length);
            for (let i = 0; i < objdata.length; i++) {
              // sel.patient_types[i] = objdata[i].termName;
              // console.log("data0="+i+":" + sel.patient_types[i]);
              _this.patient_types.splice(i, 0, {
                "item-value": objdata[i].termId,
                "item-text": objdata[i].termName
              });
            }
            // console.log("sel.patient_types[i]=" + _this.patient_types);
            return _this.patient_types;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //-------------------------获取挂号类别-----------------------------------------------------------
    getreg_type() {
      let _this = this;
      fetch("http://192.168.100.253:9002/api/v1/searchdictregitem", {
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
            window.alert("查询失败error");
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.reg_types.splice(i, 0, {
                "item-value": objdata[i].itemCode,
                "item-text": objdata[i].itemName
              });
            }
            return _this.reg_types;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //---------------------------------------获取性别列表----------------------------------------------
    getgender() {
      //查询性别
      let _this = this;
      fetch(
        "http://192.168.100.253:9002/api/v1/searchdicthealthterm/gender_type",
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
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.genders.splice(i, 0, {
                "item-value": objdata[i].termId,
                "item-text": objdata[i].termName
              });
            }
            return _this.genders;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    getid_type() {
      //查询身份证件类型
      // this.get_dict_health_term("searchdicthealthterm","id_type","idcard_types");
      let _this = this;
      fetch("http://192.168.100.253:9002/api/v1/searchdicthealthterm/id_type", {
        method: "get",
        headers: {
          Accept: "text/html",
          "Content-Type": "application/json"
        }
      })
        .then(function(response) {
          if (response.ok) {
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.idcard_types.splice(i, 0, {
                "item-value": objdata[i].termId,
                "item-text": objdata[i].termName
              });
            }
            return _this.idcard_types;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    getdept_codes() {
      //查询科室列表
      let _this = this;
      fetch(
        "http://192.168.100.253:9002/api/v1/searchdictdepartment/clinical",
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
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.dept_codes.splice(i, 0, {
                "item-value": objdata[i].deptCode,
                "item-text": objdata[i].deptName
              });
            }
            return _this.idcard_types;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    dept_codeChanged() {
      let tdept_code = this.out_reg.deptCode;
      let tpost_tech = "1";
      this.doctor_codes = [];
      this.getdoctor_codes(tdept_code, tpost_tech);
    },
    getdoctor_codes(tdept_code, tpost_tech) {
      //查询本科室可以挂号的专家列表
      let _this = this;
      fetch(
        "http://192.168.100.253:9002/api/v1/searchdictpersonreg/" +
          tdept_code +
          "|" +
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
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.doctor_codes.splice(i, 0, {
                "item-value": objdata[i].personId,
                "item-text": objdata[i].personName
              });
            }
            return _this.doctor_codes;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //------------------获取省份列表---------------------------
    getprovs() {
      let _this = this;
      fetch("http://192.168.100.253:9002/api/v1/searchdictprov", {
        method: "get",
        headers: {
          Accept: "text/html",
          "Content-Type": "application/json"
        }
      })
        .then(function(response) {
          if (response.ok) {
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.addr_provs.splice(i, 0, {
                "item-value": objdata[i].provinceId,
                "item-text": objdata[i].name
              });
            }
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //------------------获取指定省份的市列表---------------------------
    prov_Changed() {
      let tprovid = this.out_reg.addrProv;
      this.getcitys(tprovid);
    },
    getcitys(tprovid) {
      let _this = this;
      fetch("http://192.168.100.253:9002/api/v1/searchdictcity/" + tprovid, {
        method: "get",
        headers: {
          Accept: "text/html",
          "Content-Type": "application/json"
        }
      })
        .then(function(response) {
          if (response.ok) {
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.addr_citys.splice(i, 0, {
                "item-value": objdata[i].cityId,
                "item-text": objdata[i].name
              });
            }
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //------------------获取指定市的区县列表---------------------------
    city_Changed() {
      let tcityid = this.out_reg.addrCity;
      this.getcountys(tcityid);
    },
    getcountys(tcityid) {
      let _this = this;
      fetch("http://192.168.100.253:9002/api/v1/searchdictcounty/" + tcityid, {
        method: "get",
        headers: {
          Accept: "text/html",
          "Content-Type": "application/json"
        }
      })
        .then(function(response) {
          if (response.ok) {
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.addr_countys.splice(i, 0, {
                "item-value": objdata[i].countryId,
                "item-text": objdata[i].name
              });
            }
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //------------------获取指定区县的街道列表---------------------------
    county_Changed() {
      let tcountyid = this.out_reg.addrCounty;
      this.getstreets(tcountyid);
    },
    getstreets(tcountyid) {
      let _this = this;
      fetch(
        "http://192.168.100.253:9002/api/v1/searchdictstreet/" + tcountyid,
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
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              _this.addr_townships.splice(i, 0, {
                "item-value": objdata[i].townId,
                "item-text": objdata[i].name
              });
            }
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    },
    //从词典获取信息----------------暂时不用，没有解决this之后动态变量的问题------------------
    get_dict_health_term(tschmethod, tclassid, toutarrays) {
      let _this = this;
      console.log("in=" + tschmethod + " | " + tclassid + " | " + toutarrays);
      fetch(
        "http://192.168.100.253:9002/api/v1/" + tschmethod + "/" + tclassid,
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
            // window.alert('ok');
          } else {
            window.alert("查询失败error" + response.err);
          }
          return response.json();
        })
        .then(function(data) {
          let tresultCode = data.resultCode;
          if (tresultCode === "0") {
            let objdata = JSON.parse(data.outdata);
            for (let i = 0; i < objdata.length; i++) {
              console.log(
                "_this.toutarrays=" +
                  _this.toutarrays +
                  " toutarrays=" +
                  toutarrays
              );
              _this.toutarrays.splice(i, 0, objdata[i].termName);
            }
            return _this.toutarrays;
          } else {
            //登录失败
            window.alert("查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("查询error=" + err);
        });
    }
    // ---------------------end methods----------------
  }
};
</script>

<style></style>
