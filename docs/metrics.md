# Metrics
This document provides information about details about the Prometheus
exposed endpoints.

## Fluentd

The Fluentd Prometheus endpoint is provided by the [fluent-plugin-prometheus](https://github.com/fluent/fluent-plugin-prometheus) plugin.

A sample of the provided metrics:
```
# TYPE fluentd_status_buffer_queue_length gauge
# HELP fluentd_status_buffer_queue_length Current buffer queue length.
fluentd_status_buffer_queue_length{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",plugin_category="output",type="elasticsearch"} 0.0
fluentd_status_buffer_queue_length{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",plugin_category="output",type="elasticsearch"} 1.0

# TYPE fluentd_status_buffer_total_bytes gauge
# HELP fluentd_status_buffer_total_bytes Current total size of queued buffers.
fluentd_status_buffer_total_bytes{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",plugin_category="output",type="elasticsearch"} 1452.0
fluentd_status_buffer_total_bytes{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",plugin_category="output",type="elasticsearch"} 143279.0

# TYPE fluentd_status_retry_count gauge
# HELP fluentd_status_retry_count Current retry counts.
fluentd_status_retry_count{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",plugin_category="output",type="elasticsearch"} 0.0
fluentd_status_retry_count{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",plugin_category="output",type="elasticsearch"} 0.0

# TYPE fluentd_output_status_buffer_queue_length gauge
# HELP fluentd_output_status_buffer_queue_length Current buffer queue length.
fluentd_output_status_buffer_queue_length{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",type="elasticsearch"} 0.0
fluentd_output_status_buffer_queue_length{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",type="elasticsearch"} 1.0

# TYPE fluentd_output_status_buffer_total_bytes gauge
# HELP fluentd_output_status_buffer_total_bytes Current total size of queued buffers.
fluentd_output_status_buffer_total_bytes{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",type="elasticsearch"} 1452.0
fluentd_output_status_buffer_total_bytes{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",type="elasticsearch"} 143279.0

# TYPE fluentd_output_status_retry_count gauge
# HELP fluentd_output_status_retry_count Current retry counts.
fluentd_output_status_retry_count{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",type="elasticsearch"} 0.0
fluentd_output_status_retry_count{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",type="elasticsearch"} 0.0

# TYPE fluentd_output_status_num_errors gauge
# HELP fluentd_output_status_num_errors Current number of errors.
fluentd_output_status_num_errors{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",type="elasticsearch"} 0.0
fluentd_output_status_num_errors{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",type="elasticsearch"} 0.0

# TYPE fluentd_output_status_emit_count gauge
# HELP fluentd_output_status_emit_count Current emit counts.
fluentd_output_status_emit_count{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",type="elasticsearch"} 318.0
fluentd_output_status_emit_count{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",type="elasticsearch"} 1804.0

# TYPE fluentd_output_status_emit_records gauge
# HELP fluentd_output_status_emit_records Current emit records.

# TYPE fluentd_output_status_write_count gauge
# HELP fluentd_output_status_write_count Current write counts.

# TYPE fluentd_output_status_rollback_count gauge
# HELP fluentd_output_status_rollback_count Current rollback counts.

# TYPE fluentd_output_status_retry_wait gauge
# HELP fluentd_output_status_retry_wait Current retry wait
fluentd_output_status_retry_wait{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-ops",type="elasticsearch"} 0.0
fluentd_output_status_retry_wait{hostname="logging-fluentd-28j4d",plugin_id="elasticsearch-apps",type="elasticsearch"} 0.0
```
