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
  {{- with $deploymentValues.Values.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  template:
    spec:
      {{- if $deploymentValues.Values.imagePullSecrets }}
      imagePullSecrets:
        - name: {{ $deploymentValues.Values.imagePullSecrets }}
      {{- end }}
      {{- with $deploymentValues.Values.podSecurityContext }}
      securityContext:
{{ toYaml . | indent 8 }}
      {{- end }}
      containers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with include "base.podDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- with $containerValues.volumeMounts }}
          volumeMounts:
{{ toYaml . | indent 12 }}
          {{- end }}
        {{- end }}
        - name: {{ include "base.name" $deploymentValues }}
          {{- include "base.image" $deploymentValues.Values.image | nindent 10 }}
          {{- with include "base.podDefaultProperties" $deploymentValues.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- with $deploymentValues.Values.volumeMounts }}
          volumeMounts:
{{ toYaml . | indent 12 }}
          {{- end }}
      {{- with include "base.NodeScheduling" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- with include "base.volumes" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      restartPolicy: {{ $deploymentValues.Values.restartPolicy }}
  backoffLimit: {{ $deploymentValues.Values.backoffLimit | toString }}
{{- end }}
{{- end }}