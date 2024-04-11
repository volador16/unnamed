/**
 * @brief: 该文件定义了视频解码模块的接口，及其说明。
 *      为便于编译后的library给其它语言调用，这里采用了ANSI C语言.并约定所有的接口都以'DEC_'开头。
 * @author: zuo.jin
 * @date: 2024-04-02
 */
#ifndef DEC_INTERFACE_H
#define DEC_INTERFACE_H
/*
extern "C" {
#include <libavformat/avformat.h>
#include <libavformat/avio.h>
#include <libavcodec/avcodec.h>
}
*/
/**
 * @brief: 要解码视频的编码方式，目前只支持H264,H265两种压缩编码。
 */
enum DEC_CODEC{
    DEC_H264,
    DEC_H265
};
/**
 * @brief: 一个解码器的对象封装。每一个视频输入的解码都需要先获得一个handler，不需要解码后要释放它.
 */
struct DEC_Handler{
    
};

/**
 * @brief: 初始化一个视频解码器。
 */
const DEC_Handler* DEC_init();

#endif
