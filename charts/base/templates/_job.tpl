{{- define "base.job" -}}
{{- $root := . -}}
{{- range $deploymentName, $deploymentValuesOverride := .Values.deployments }}
{{- $deploymentValues := merge dict $deploymentValuesOverride $root }}
---
apiVersion: {{ $deploymentValues.Values.apiVersion | default "batch/v1" }}
kind: Job
metadata:
{{- if eq ( $deploymentName ) "default" }}
  name: {{ include "base.fullname" $deploymentValues }}
{{- else if $deploymentValues.fullnameOverride }}
  name: {{ include "base.fullname" $deploymentValues }}
{{- else }}
  name: {{ $deploymentName }}
{{- end }}
  {{- if $deploymentValues.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $deploymentValues.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  template:
    spec:
      {{- with include "base.containerDefaultProperties" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- if $deploymentValues.Values.initContainers }}
      initContainers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.initContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with include "base.podDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with include "base.podDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
        - name: {{ include "base.name" $deploymentValues }}
          {{- include "base.image" $deploymentValues.Values.image | nindent 10 }}
          {{- with include "base.podDefaultProperties" $deploymentValues.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
      {{- with include "base.volumes" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      restartPolicy: {{ $deploymentValues.Values.restartPolicy }}
  backoffLimit: {{ $deploymentValues.Values.backoffLimit | toString }}
{{- end }}
{{- end }}