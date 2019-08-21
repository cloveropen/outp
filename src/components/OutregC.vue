<template>
  <v-container class="grey lighten-5">
    <v-form ref="form" v-model="valid" lazy-validation>
      <v-card class="mx-auto" max-width="99%" min-width="100%">
        <v-img class="white--text" height="60px" :src="require('../assets/outreg.jpg')">
          <v-card-title class="align-end fill-height">门诊挂号</v-card-title>
        </v-img>

        <v-card-text>
          <v-layout row wrap>
            &emsp;&emsp;
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
              &emsp;&emsp;
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
              &emsp;&emsp;
              <v-text-field
                v-model="out_reg.patientName"
                label="患者姓名"
                required
                :counter="6"
                :rules="nameRules"
              ></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="out_reg.idcard" label="身份证号" disabled></v-text-field>&emsp;&emsp;
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            &emsp;&emsp;
            <v-flex d-flex>
              <v-text-field v-model="out_reg.pid" label="门诊号" disabled></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
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
                  &emsp;&emsp;
                  <v-text-field v-model="out_reg.ageY" label="年龄(岁)"></v-text-field>
                </v-flex>
                <v-flex d-flex>
                  &emsp;&emsp;
                  <v-text-field v-model="out_reg.ageM" label="年龄(月)"></v-text-field>
                </v-flex>
                <v-flex d-flex>
                  &emsp;&emsp;
                  <v-text-field v-model="out_reg.ageD" label="年龄(天)"></v-text-field>&emsp;&emsp;
                </v-flex>
              </v-layout>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
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
              &emsp;&emsp;
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
                @input="dept_codeChanged($event)"
              ></v-select>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
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
              &emsp;&emsp;
              <v-switch v-model="out_reg.visitPriority" label="就诊优先"></v-switch>
            </v-flex>
          </v-layout>
          <v-layout row wrap>
            <v-flex d-flex>
              &emsp;&emsp;
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
              &emsp;&emsp;
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
              &emsp;&emsp;
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
              ></v-select>&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
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
              ></v-select>&emsp;&emsp;
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-text-field v-model="out_reg.addrHouseNmb" label="单位或住址(详细地址)"></v-text-field>
            </v-flex>
            <v-flex d-flex>
              &emsp;&emsp;
              <v-select
                v-model="out_reg.idcardType"
                :items="idcard_types"
                item-text="item-text"
                item-value="item-value"
                label="证件类型"
                hide-details
                prepend-icon="map"
                single-line
              ></v-select>&emsp;&emsp;
            </v-flex>
          </v-layout>
          <!-- <v-spacer></v-spacer>           -->
          <v-row>
            <v-col cols="6">
              <v-card class="pa-4" tile elevation="18">
                <div
                  align="right"
                  class="title"
                >挂号费合计:&nbsp;&nbsp;{{out_reg.regPrice + out_reg.CheckupPrice}}&emsp;&emsp;&emsp;&emsp;</div>
              </v-card>
            </v-col>
            <v-col cols="3">
              <v-card class="pa-4" tile elevation="20">
                <div class="subtitle-1">其中挂号费:&nbsp;&nbsp;{{ out_reg.regPrice }}</div>
              </v-card>
            </v-col>
            <v-col cols="3">
              <v-card class="pa-4" tile elevation="20">
                <div class="subtitle-1">其中诊察费:&nbsp;&nbsp;{{ out_reg.CheckupPrice }}</div>
              </v-card>
            </v-col>
          </v-row>

          <v-row>
            <v-col sm="12">
              <!-- <v-card class="pa-2" outlined tile>就诊人信息</v-card> -->
              <v-row no-gutters>
                <v-col cols="6" sm="7">
                  <v-card class="pa-4" elevation="18" >
                    <div>
                      <video ref="video" id="video" width="640" height="480" autoplay></video>
                    </div>
                    <!-- <div>
                      <button id="snap" v-on:click="capture()">Snap Photo</button>
                    </div>
                    <canvas ref="canvas" id="canvas" width="640" height="480"></canvas>
                    <ul>
                      <v-list v-for="c in captures" :key="c">
                        <img v-bind:src="c" height="50" />
                      </v-list>
                    </ul> -->
                  </v-card>
                </v-col>
                <v-col cols="6" sm="5">
                  <v-card class="pa-4" elevation="18" tile>
                    <v-row>
                      <v-col cols="12">
                        <div class="title">患者医保信息</div>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;医保个人编号:{{ out_reg.micard }}</div>
                      </v-col>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;医保卡余额:{{ out_reg.miPaccLeft }}</div>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;医保类别:{{ out_reg.miType }}</div>
                      </v-col>
                      <v-col cols="6">
                        <div class="subtitle-1">&emsp;&emsp;参保单位:{{ out_reg.miCompany }}</div>
                      </v-col>
                    </v-row>
                    <v-row>
                      <v-col cols="12">
                        <div class="subtitle-1">&emsp;&emsp;读卡信息:{{ out_reg.miStr }}</div>
                      </v-col>
                    </v-row>
                  </v-card>
                </v-col>
              </v-row>
            </v-col>
          </v-row>
        </v-card-text>

        <v-card-actions>
          <div align="center">
            <v-btn id="snap" :disabled="!valid" color="success" @click="capture">拍照</v-btn>
            <v-btn :disabled="!valid" color="success" @click="validate">读健康卡</v-btn>
            <v-btn :disabled="!valid" color="success" @click="readcard_mi">读医保卡</v-btn>
            <v-btn :disabled="!valid" color="success" @click="outreg_cash">现金挂号</v-btn>
            <v-btn :disabled="!valid" color="success" @click="outreg_weixin">微信挂号</v-btn>
            <v-btn :disabled="!valid" color="success" @click="sch_weixin">查询微信订单</v-btn>
            <v-btn color="error" @click="reset">下一位</v-btn>
            <v-btn color="warning" @click="resetValidation">返回主页</v-btn>
          </div>
        </v-card-actions>
      </v-card>
    </v-form>
  </v-container>
</template>
<script>
var player = document.getElementById("player");
var snapshotCanvas = document.getElementById("snapshot");
var captureButton = document.getElementById("capture");

var handleSuccess = function(stream) {
  // Attach the video stream to the video element and autoplay.
  player.srcObject = stream;
};

captureButton.addEventListener("click", function() {
  var context = snapshot.getContext("2d");
  // Draw the video frame to the canvas.
  context.drawImage(player, 0, 0, snapshotCanvas.width, snapshotCanvas.height);
});

navigator.mediaDevices.getUserMedia({ video: true }).then(handleSuccess);
</script>
<script>
import {
  getpatient_type,
  get_regopcode,
  getgender,
  getid_type,
  getreg_type,
  getdept_codes,
  getdoctor_codes,
  getprovs,
  getcitys,
  getcountys,
  getstreets
} from "../scripts/outreg.js";

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
      addrProv: process.env.VUE_APP_HSP_PROV, //地址
      addrCity: process.env.VUE_APP_HSP_CITY,
      addrCounty: process.env.VUE_APP_HSP_COUNTY,
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
    },
    video: {},
    canvas: {},
    captures: []
  }),
  created() {
    this.out_reg.regOpcode = get_regopcode();
    this.patient_types = getpatient_type();
    this.genders = getgender();
    this.idcard_types = getid_type();
    this.reg_types = getreg_type();
    this.dept_codes = getdept_codes();
    this.addr_provs = getprovs();
    this.addr_citys = getcitys(process.env.VUE_APP_HSP_PROV);
  },
  mounted() {
    this.video = this.$refs.video;
    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
      navigator.mediaDevices.getUserMedia({ video: true }).then(stream => {
        this.video.srcObject = stream;
        this.video.play();
      });
    }
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
    test() {
      console.log("1");
      this.patient_types = getpatient_type();
      console.log("2");
      console.log(this.patient_types.length);
    },
    //------------------------确认现金挂号------------------------------------------------------------
    outreg_cash() {
      // let _this = this;
      console.log(
        "JSON.stringify(this.out_reg)=" + JSON.stringify(this.out_reg)
      );
      fetch(process.env.VUE_APP_REG_URL + "/saveoutreg", {
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
    },
    //------------------------确认微信挂号------------------------------------------------------------
    outreg_weixin() {
      console.log(this.$refs.form.data);
    },
    //-------------------------查询微信订单-----------------------------------------------------------
    sch_weixin() {
      console.log(this.$refs.form.data);
    },
    getpatient(e) {
      let texpid = e;
      if (texpid.length < 13) {
        return;
      }
      let _this = this;
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
            let toutreg = JSON.parse(data.outdata);
            _this.out_reg = toutreg;
            _this.get_regopcode();
            // console.log("sel.patient_types[i]=" + _this.patient_types);
            return _this.out_reg;
          } else {
            //登录失败
            window.alert("根据条码号获取患者信息查询失败1");
          }
        })
        .catch(function(err) {
          window.alert("根据条码号获取患者信息查询error=" + err);
        });
    },

    dept_codeChanged(e) {
      let tdept_code = this.out_reg.deptCode;
      console.log("e=" + e);
      let tpost_tech = "1";
      this.doctor_codes = getdoctor_codes(tdept_code, tpost_tech);
    },

    //------------------获取指定省份的市列表---------------------------
    prov_Changed() {
      let tprovid = this.out_reg.addrProv;
      this.addr_citys = getcitys(tprovid);
    },

    //------------------获取指定市的区县列表---------------------------
    city_Changed() {
      let tcityid = this.out_reg.addrCity;
      this.addr_countys = getcountys(tcityid);
    },

    //------------------获取指定区县的街道列表---------------------------
    county_Changed() {
      let tcountyid = this.out_reg.addrCounty;
      this.addr_townships = getstreets(tcountyid);
    },
    capture() {
      this.canvas = this.$refs.canvas;
      var ctx = this.canvas.getContext("2d");
      ctx.drawImage(this.video, 0, 0, 640, 480);
      this.captures.push(this.$refs.canvas.toDataURL("image/png"));
    }

    // ---------------------end methods----------------
  }
};
</script>

<style></style>
