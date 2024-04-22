{{- define "base.storageClasses" -}}
{{- if .Values.storageClasses }}
{{- $root := . -}}
{{- range .Values.storageClasses }}
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ .name }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
{{- with .parameters }}
parameters:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if .provisioner  }}
provisioner: {{ .provisioner }}
{{- end }}
reclaimPolicy: {{ .reclaimPolicy | default "Retain" }}
allowVolumeExpansion: {{ hasKey . "allowVolumeExpansion" | ternary .allowVolumeExpansion true }}
volumeBindingMode: {{ .volumeBindingMode | default "Immediate" }}
{{- end }}
{{- end }}
{{- end }}