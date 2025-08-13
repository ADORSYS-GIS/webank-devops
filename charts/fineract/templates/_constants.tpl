{{- define "constant.db.url" -}}
{{- $dbName := include "common.tplvalues.render" (dict "value" .Values.database.name "context" $) -}}
{{- $dbHost := include "common.tplvalues.render" (dict "value" .Values.database.host "context" $) -}}
{{- $dbPort := include "common.tplvalues.render" (dict "value" .Values.database.port "context" $) -}}
jdbc:postgresql://{{ $dbHost }}:{{ $dbPort }}/{{ $dbName }}
{{- end -}}