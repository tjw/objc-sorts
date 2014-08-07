//
//  Jesse Squires
//  http://www.jessesquires.com
//
//  GitHub
//  https://github.com/jessesquires/objc-sorts
//
//  Copyright (c) 2014 Jesse Squires
//

#import <Foundation/Foundation.h>

#import "sorts.h"
#import "sortUtils.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        const NSUInteger MAX_COUNT = 10000;
        
        const NSUInteger NUM_TRIALS = 10;
        
        NSArray *sortAlgorithms = [NSArray arrayWithObjects:@(SortAlgorithmTypeObjC),
                                   @(SortAlgorithmTypeQuick),
                                   @(SortAlgorithmTypeHeap),
                                   @(SortAlgorithmTypeInsertion),
                                   @(SortAlgorithmTypeSelection),
                                   @(SortAlgorithmTypeMerge),
                                   @(SortAlgorithmTypeBubble),
                                   nil];
        

        // Baseline
        {
            CFAbsoluteTime total = 0;
            for (NSUInteger trial = 0; trial < NUM_TRIALS; trial++) {
                CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
                NSInteger *unsortUnboxedIntegers = randomUnboxedIntegerArray(MAX_COUNT);
                qsort_b(unsortUnboxedIntegers, MAX_COUNT, sizeof(*unsortUnboxedIntegers), ^int(const void *p1, const void *p2) {
                    NSInteger a = *(const NSInteger *)p1;
                    NSInteger b = *(const NSInteger *)p2;
                    
                    if (a < b)
                        return 1;
                    if (a > b)
                        return -1;
                    return 0;
                });
                CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
                total += (end - start);
                free(unsortUnboxedIntegers);
            }
            
            NSLog(@"Baseline: %fs", total/NUM_TRIALS);
        }
        
        NSMutableDictionary *averageSortTimes = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@(0.0), @(0.0), @(0.0), @(0.0), @(0.0), @(0.0), @(0.0), nil]
                                                                                   forKeys:sortAlgorithms];
        
        for (NSUInteger t = 1; t <= NUM_TRIALS; t++) {
            NSLog(@"\n\n::: TRIAL %ld :::", t);
            
            NSMutableArray *unsortedArray = randomIntegerArray(MAX_COUNT);

            for (NSNumber *sort in sortAlgorithms) {
                NSUInteger sortType = sort.integerValue;
                
                NSTimeInterval sortTime = 0.0;
                
                switch (sortType) {
                    case SortAlgorithmTypeObjC:
                        sortTime = sortArrayWithNameUsingBlock(unsortedArray, sortType, ^(NSMutableArray *arr) {
                            objcSort(arr);
                        });
                        break;
                        
                    case SortAlgorithmTypeQuick:
                        sortTime = sortArrayWithNameUsingBlock(unsortedArray, sortType, ^(NSMutableArray *arr) {
                            quickSort(arr);
                        });
                        break;
                        
                    case SortAlgorithmTypeHeap:
                        sortTime = sortArrayWithNameUsingBlock(unsortedArray, sortType, ^(NSMutableArray *arr) {
                            heapSort(arr);
                        });
                        break;
                        
                    case SortAlgorithmTypeInsertion:
                        sortTime = sortArrayWithNameUsingBlock(unsortedArray, sortType, ^(NSMutableArray *arr) {
                            insertionSort(arr);
                        });
                        break;
                        
                    case SortAlgorithmTypeSelection:
                        sortTime = sortArrayWithNameUsingBlock(unsortedArray, sortType, ^(NSMutableArray *arr) {
                            selectionSort(arr);
                        });
                        break;
                        
                    case SortAlgorithmTypeMerge:
                        sortTime = sortArrayWithNameUsingBlock(unsortedArray, sortType, ^(NSMutableArray *arr) {
                            mergeSort(arr);
                        });
                        break;
                        
                    case SortAlgorithmTypeBubble:
                        sortTime = sortArrayWithNameUsingBlock(unsortedArray, sortType, ^(NSMutableArray *arr) {
                            bubbleSort(arr);
                        });
                        break;
                }
                
                NSTimeInterval totalTime = [[averageSortTimes objectForKey:sort] doubleValue];
                [averageSortTimes setObject:@(totalTime + sortTime) forKey:sort];
            }
        }
        
        NSLog(@"\n\nFinal Results:\n--------------");
        
        [averageSortTimes enumerateKeysAndObjectsUsingBlock:^(NSNumber *sortType, NSNumber *time, BOOL *stop) {
            NSLog(@"%@ sort average time = %lf sec", sortAlgorithmNameForType(sortType.integerValue), time.doubleValue / NUM_TRIALS);
        }];
        
        NSLog(@"\n");
    }
    
    return 0;
}
