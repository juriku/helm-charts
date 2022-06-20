{{- define "base.service" -}}
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
  labels:
    {{- include "base.labels" $root | nindent 4 }}
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
  {{- range $key, $value := $serviceValues.ports }}
    - port: {{ $value }}
      targetPort: {{ $key | quote }}
      protocol: TCP
      name: {{ $key | quote }}
      {{- if $serviceValues.nodePort }}
      nodePort: {{ $serviceValues.nodePort }}
      {{- end }}
  {{- end }}
  {{- else if $root.Values.containerPorts }}
  {{- range $key, $value := $root.Values.containerPorts }}
    - port: {{ $value }}
      targetPort: {{ $key | quote }}
      protocol: TCP
      name: {{ $key | quote }}
  {{- end }}
  {{- end }}
  selector:
    {{- include "base.selectorLabels" $root | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
