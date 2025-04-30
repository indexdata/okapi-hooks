{{- define "module-descriptor" -}}
{{- $content := .Files.Get "ModuleDescriptor-template.json" | replace "@version@" .Chart.Version -}}
{{- $content -}}
{{- end -}}
