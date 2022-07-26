{{- define "base.job" -}}
{{- $deploymentValues := . -}}
---
apiVersion: {{ $deploymentValues.Values.apiVersion | default "batch/v1" }}
kind: Job
metadata:
  name: {{ include "base.fullname" $deploymentValues }}
  labels:
    {{- include "base.commonLabels" $deploymentValues | trim | nindent 4 }}
  {{- if $deploymentValues.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $deploymentValues.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  template:
    {{- if or $deploymentValues.Values.podAnnotations $deploymentValues.Values.podLabels }}
    metadata:
      {{- if $deploymentValues.Values.podAnnotations }}
      annotations:
        {{- include "base.valuesPairs" $deploymentValues.Values.podAnnotations | trim | nindent 8 }}
      {{- end }}
      {{- with $deploymentValues.Values.podLabels }}
      labels:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    {{- end }}
    spec:
      {{- with include "base.podDefaultProperties" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- if $deploymentValues.Values.initContainers }}
      initContainers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.initContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
        - name: {{ include "base.name" $deploymentValues }}
          {{- include "base.image" $deploymentValues.Values.image | nindent 10 }}
          {{- with include "base.containerDefaultProperties" $deploymentValues.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
      {{- with include "base.volumes" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      restartPolicy: {{ $deploymentValues.Values.restartPolicy }}
  backoffLimit: {{ $deploymentValues.Values.backoffLimit | toString }}
{{- end }}