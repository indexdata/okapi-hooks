{{/* Validation for required values */}}
{{- define "okapi-hooks.validateValues" -}}
{{- if not .Values.okapiUrl -}}
{{- fail "A valid .Values.okapiUrl is required!" -}}
{{- end -}}
{{- if not .Values.okapiSecret -}}
{{- fail "A valid .Values.okapiSecret is required!" -}}
{{- end -}}
{{- if not .Values.moduleUrl -}}
{{- fail "A valid .Values.moduleUrl is required!" -}}
{{- end -}}
{{- if not .Values.moduleDescriptor -}}
{{- fail "A valid .Values.moduleDescriptor is required!" -}}
{{- end -}}
{{- end -}}
