#!/usr/bin/env bash
##
## SPDX-License-Identifier: LGPL-2.1-only
##
## @file runTest.sh
## @author Harsh Jain <hjain24in@gmail.com>
## @date 18 JUNE, 2023
## @brief SSAT Test Cases for NNStreamer
##
if [[ "$SSATAPILOADED" != "1" ]]; then
    SILENT=0
    INDEPENDENT=1
    search="ssat-api.sh"
    source $search
    printf "${Blue}Independent Mode${NC}"
fi

# This is compatible with SSAT (https://github.com/myungjoo/SSAT)
testInit $1

PATH_TO_PLUGIN="../../build"
PATH_TO_IMAGE="../test_models/data/orange.png"
PATH_TO_LABELS="../nnstreamer_decoder_boundingbox/coco_labels_list.txt"
PATH_TO_BOX_PRIORS="../nnstreamer_decoder_boundingbox/box_priors.txt"
PATH_TO_MODEL="../test_models/models/ssd_mobilenet_v2_coco.tflite"


gstTest "--gst-plugin-path=${PATH_TO_PLUGIN} filesrc location=${PATH_TO_IMAGE} ! decodebin ! videoconvert ! videoscale ! video/x-raw,width=640,height=480,format=RGB ! videoscale ! video/x-raw,width=300,height=300,format=RGB ! tensor_converter ! tensor_transform mode=arithmetic option=typecast:float32,add:-127.5,div:127.5 ! tensor_filter framework=tensorflow2-lite model=${PATH_TO_MODEL} ! tensor_decoder mode=tensor_region option1=1 option2=${PATH_TO_LABELS} option3=${PATH_TO_BOX_PRIORS} ! queue ! filesink location=tensor_region.output.0" 0 0 0 $PERFORMANCE

callCompareTest tensor_region.0 tensor_region.output.0 0 "mobilenet-ssd Decode 1" 0
rm tensor_region.output.*
report