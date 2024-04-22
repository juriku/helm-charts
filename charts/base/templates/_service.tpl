{{- define "base.service" -}}
{{- if .Values.service.enabled -}}
{{- $root := . -}}
{{- $serviceNameOne := .Values.service.name | default (include "base.fullname" .) -}}
{{- $serviceValuesOne := .Values.service }}
{{- $servicesMap := dict $serviceNameOne $serviceValuesOne }}
{{- if .Values.extraServices }}
{{- $servicesMap := merge $servicesMap .Values.extraServices }}
{{- end }}
{{- range $serviceName, $serviceValues := $servicesMap }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $serviceName }}
  {{- if $serviceValues.namespace }}
  namespace: {{ $serviceValues.namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
    {{- with $serviceValues.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $serviceValues.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $serviceValues.externalTrafficPolicy }}
  externalTrafficPolicy: {{ $serviceValues.externalTrafficPolicy }}
  {{- end }}
  {{- if $serviceValues.loadBalancerIP }}
  loadBalancerIP: {{ $serviceValues.loadBalancerIP | quote }}
  {{- end }}
  {{- if $serviceValues.clusterIP }}
  clusterIP: {{ $serviceValues.clusterIP | quote }}
  {{- end }}
  {{- if $serviceValues.sessionAffinity }}
  sessionAffinity: {{ $serviceValues.sessionAffinity | quote }}
  {{- end }}
  {{- if $serviceValues.ExternalName }}
  type: ExternalName
  externalName: {{ $serviceValues.ExternalName | quote }}
  {{- else }}
  type: {{ $serviceValues.type | default "ClusterIP" }}
  ports:
  {{- if $serviceValues.ports }}
  {{- range $i, $a := $serviceValues.ports }}
    - port: {{ $a.port }}
      targetPort: {{ $a.targetPort | default $a.port }}
      protocol: {{ $a.protocol | default "TCP" }}
      name: {{ $a.name | default (printf "http-%s" (toString $i))  }}
      {{- if $a.nodePort }}
      nodePort: {{ $a.nodePort }}
      {{- end }}
  {{- end }}
  {{- else if $root.Values.ports }}
  {{- range $i, $a := $root.Values.ports }}
    - port: {{ $a.containerPort }}
      targetPort: {{ $a.containerPort }}
      protocol: {{ $a.protocol | default "TCP" }}
      name: {{ $a.name | default (printf "http-%s" (toString $i))  }}
  {{- end }}
  {{- end }}
  selector:
    {{- if $serviceValues.selector }}
    {{- with $serviceValues.selector }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
    {{- else }}
    {{- include "base.selectorLabels" $root | trim | nindent 4 }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}