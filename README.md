## 【題目一】
**作法：**
1. 靜態資源全部上 CDN。
2. 高頻查詢掛 Redis 緩存，擋掉直接進 DB 的流量。
3. 服務設定 auto-scaling 機制（HPA, ScaledObjects）
4. 若能跟商務端討論並預測推廣確切時間，可把 k8s HPA 跟 Node Group 提早手動 scale-out 擴容，RDS 讀寫分離配好，增加 Read Replica。
5. 在 WAF 或 nginx 層設 Rate Limit 限流

## 【題目二】
**排查步驟：**
1. 先止血：先把這台機器從 LB 或 K8s Service 拔掉 (Drain Node 或 Delete Pod)，不要再接新流量。
2. 看監控：查 Grafana 的 CPU、Memory (看有沒有 OOM)、Disk I/O Wait。
3. 查 Log：看是不是 DB connection pool 滿了、卡 GC 還是戳外部 API 逾時。
4. 若能看到 error log，再去查對應 source code 有沒有問題，同步回報給 developer

## 【題目三】
**排查步驟：**
1. 嘗試用 AWS SSM Session Manager 連進去。若失敗可以再用 Serial Console 連進去試試
2. 不行的話，從 AWS Console 軟重啟 (Reboot)，再不行就硬重啟。
3. 要抓 root cause 的話，把這台關機，EBS 拆下來掛到另一台正常的機器，去查 `/var/log/syslog` 或 `messages`。

**可能原因：**
- Disk 滿了：最常見，導致 `sshd` 寫不進 log 或 pid，直接拒絕連線。
- OOM：系統沒記憶體，OOM Killer 把 `sshd` 砍了。
- CPU 滿載：系統卡死導致 SSH 握手逾時。
- 權限跑掉：`sshd_config` 或 `~/.ssh/authorized_keys` 權限被改壞。

## 【題目四】
**作法：**
1. 收集：K8s 用 DaemonSet 起 Fluent Bit 或 Filebeat 抓 container 的 stdout 日誌。
2. 格式：要求開發直接噴 JSON 格式，省去把資料結構化的 CPU 開銷。
3. 標籤：收集端直接把 namespace, pod_name 等 metadata 塞進去，方便 Kibana 篩選。
4. 維運：Fluent Bit 要卡資源限制 (Resource Limits)；App 端要做好 Logrotate 防硬碟塞爆；ES 端要設 lifecycle 定期清掉舊資料。

