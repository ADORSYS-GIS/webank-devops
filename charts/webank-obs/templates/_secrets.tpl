{{- define "db.secret.name" -}}
{{- if $.Values.database.secretName -}}
{{- .Values.database.secretName -}}
{{- else -}}
{{- include "webank-obs.name" $ -}}-db
{{- end -}}
{{- end -}}