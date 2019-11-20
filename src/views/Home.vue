<template>
  <v-app id="outp.cloveropen.com">
    <Basepage />
    <v-container fluid fill-height>
      <v-layout justify-start row wrap>
        <v-flex d-flex>
          <div class="ih-item square colored effect9 bottom_to_top">
            <router-link :to="{ name: 'outreg' }">
              <div class="img">
                <img :src="require('../assets/img/reg.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>门诊挂号</h3>
                  <p>扫病历条码挂号或直接挂号,打印挂号单</p>
                </div>
              </div>
            </router-link>
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square colored effect9 bottom_to_top">
            <router-link :to="{ name: 'outcash' }">
              <div class="img">
                <img :src="require('../assets/img/cash.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>划价收款</h3>
                  <p>接收门诊医生工作站申请单和处方,收款打印收据</p>
                </div>
              </div>
            </router-link>
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square colored effect9 bottom_to_top">
            <router-link :to="{ name: 'outchk' }">
              <div class="img">
                <img :src="require('../assets/img/chk.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>交班结算</h3>
                  <p>交班统计本班工作量和收款额、收据张数及起止流水号</p>
                </div>
              </div>
            </router-link>
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square colored effect9 left_to_right">
            <router-link :to="{ name: 'outreceipt' }">
              <div class="img">
                <img :src="require('../assets/img/receipt.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>发票号管理</h3>
                  <p>领用挂号、收款、预交金收据登记和流水号设置</p>
                </div>
              </div>
            </router-link>
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square effect9 left_to_right">
            <router-link :to="{ name: 'detailreg' }">
              <div class="img">
                <img :src="require('../assets/img/reg_detail.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>查询挂号明细</h3>
                  <p>挂号费用明细和支付明细</p>
                </div>
              </div>
            </router-link>
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square colored effect9 left_to_right">
            <router-link :to="{ name: 'detailcash' }">
              <div class="img">
                <img :src="require('../assets/img/cash_detail.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>查询收款明细</h3>
                  <p>收款费用明细和每次结算明细</p>
                </div>
              </div>
            </router-link>
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square effect9 top_to_bottom">
            <router-link :to="{ name: 'detailinvoice' }">
              <div class="img">
                <img :src="require('../assets/img/invoice_prn.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>打印收据明细</h3>
                  <p>操作员打印收据明细记录</p>
                </div>
              </div></router-link
            >
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square colored effect9 top_to_bottom">
            <router-link :to="{ name: 'detailchk' }">
              <div class="img">
                <img :src="require('../assets/img/set_detail.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>交班结算明细</h3>
                  <p>交班结算历史记录</p>
                </div>
              </div></router-link
            >
          </div>
        </v-flex>
        <v-flex d-flex>
          <div class="ih-item square colored effect9 top_to_bottom">
            <router-link :to="{ name: 'detailundo' }">
              <div class="img">
                <img :src="require('../assets/img/undo.jpg')" alt="img" />
              </div>
              <div class="info">
                <div class="info-back">
                  <h3>退款明细</h3>
                  <p>退号退款记录</p>
                </div>
              </div>
            </router-link>
          </div>
        </v-flex>
      </v-layout>
    </v-container>
  </v-app>
</template>

<script>
import Basepage from "../components/Basepage";
export default {
  components: {
    Basepage
  }
};
</script>
<style scoped>
@import "../styles/ihover.min.css";
</style>
