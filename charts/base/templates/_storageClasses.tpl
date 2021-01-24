{{- define "base.storageClasses" -}}
{{- if .Values.storageClasses }}
{{- range .Values.storageClasses }}
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: {{ .name }}
{{- with .parameters }}
parameters:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if .provisioner  }}
provisioner: {{ .provisioner }}
{{- end }}
reclaimPolicy: {{ .reclaimPolicy | default "Retain" }}
allowVolumeExpansion: {{ .allowVolumeExpansion | default true }}
volumeBindingMode: {{ .volumeBindingMode | default "Immediate" }}
{{- end }}
{{- end }}
{{- end }}