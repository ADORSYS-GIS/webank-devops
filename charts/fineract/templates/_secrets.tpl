{{- define "db.secret.name" -}}
{{- if $.Values.database.secretName -}}
{{- .Values.database.secretName -}}
{{- else -}}
{{- include "common.names.fullname" $ -}}-db
{{- end -}}
{{- end -}}