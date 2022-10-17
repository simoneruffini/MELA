#####################################
#            QUICKSORT              #
#                                   #
# Implemented in DLX assembly.      #
#                                   #
# Luca Nassi 194675                 #
# Daniele Jahier Pagliari 196046    #
#                                   #
#####################################


################
# CODE SEGMENT #
################

	.text
	
	
## MAIN ##
# used to set up initial parameters for recursive quicksort call	
main:

		addi r30, r0, stack 	# set stack pointer to base of stack

		lw r1, array_0(r0)		# set left pointer to array elements
		lw r2, array_N(r0)		# set right pointer to array elements
	
		jal qsort				# sort array using quick sort
		
endless: 
		j endless				# wait forever
	
	
	
## QUICKSORT ##
qsort:	

		# recursion end condition
		
		sge r29, r1, r2		# if left limit is greater or equal to right limit
		bnez r29, return	# jump to end of routine and return back
		
		# save all registers that will be modified and are used again by caller
		
		sw (r30), r31		# push return address
		addi r30, r30, 4

		sw (r30), r2		# push right limit
		addi r30, r30, 4

		sw (r30), r7		# push previous saved value of right limit
		addi r30, r30, 4


		# save current left and right limits
		
		addi r6, r1, 0
		addi r7, r2, 0

		# choose pivot

		lw r3, (r1)			# leftmost element of current range is the pivot

			
		# partition current array range usign pivot

		# set initial value (out of range) for right and left limits
		
		subi r1, r1, 4		# left limit is decresed by one position
		addi r2, r2, 4		# right limit is increased by one position
		
		# find an element less or equal to the pivot in the right side
loop1:	
		subi r2, r2, 4		# decrease right limit by one position
		lw r5, (r2)			# load in r5 element pointed by right limit
		sgt r29, r5, r3		# if current element is greater than pivot
		bnez r29, loop1		# jump back to find another element

		# find an element greater or equal to the pivot in the left side		
loop2:	
		addi r1, r1, 4		# increase left limits by one position
		lw r4, (r1)			# load in r4 element pointed by left limit
		slt r29, r4, r3		# if current element is less than pivot
		bnez r29, loop2		# jump back to find another element

		sge r29, r1, r2		# if left limit is equal or greater than right one
		bnez r29, recur		# jump to recursive calls

		# swap two selected elements

		sw (r1), r5			# store in left limit position last right-side element
		sw (r2), r4			# store in right limit position last left-side element

		j loop1				# jump back to continue partitioning


recur:
		# recur on left sub-array

							# new right limit is current value of right pointer
		addi r1, r6, 0		# new left limit is equal to original one
		jal qsort			# call quick sort with new array bounds
		
		# recur on right sub-array
		
		addi r1, r2, 4		# new left limit is one position after right pointer
		addi r2, r7, 0		# new right limit is equal to original one
		jal qsort			# call quick sort with new array bounds


		# restore previous values of saved registers
		
		subi r30, r30, 4	# pop previous saved value of right limit
		lw r7, (r30)
		
		subi r30, r30, 4	# pop right limit
		lw r2, (r30)
				
		subi r30, r30, 4	# pop return address
		lw r31, (r30)

return:
		jr r31				# return to calling routine
		

# NOTES to Quick Sort assembly algorithm
#
# How registers are used in this implementation of quick sort
#
#			r1  : left pointer to current element
#			r2  : right pointer to current element
#			r3  : pivot value for quick sort
#			r4  : current left element
#			r5  : current right element
#			r6  : saved value of starting left limit
#			r7  : saved value of starting right limit
#			r29 : result of comparisons between other registers
#			r30 : stack pointer
#			r31 : link register by defulat (return address after jal)
#
# Registers r1, r3, r4, r5, r6, r29 are not saved and restored through stack
# while recurring, because their values are created and used without
# being interleaved with recursive calls, and are never used again later.
#

################
# DATA SEGMENT #
################

	.data

code_space:
	.space 256

# The available assembler assigns addresses starting from zero each time
# it finds a new segment. In this way data and text segments are going to 
# overlap and their addresses cannot be shared. To avoid this problem we 
# need to generate absolute code in which starting address of data segment
# is located after last address of text segment. Therefore we use a trick 
# reserving the first part of data segment (code_space) to empty space while
# all useful data structures are defined soon after. In this way, when 
# compiling, the text segment would overlap the data segment just for this
# initial empty space so that as result we have the compiled code followed
# by useful data addresses. Obviously the size of code_space has to be enough
# to contain all compiled code (256 byte are more than enough). 


# array to be sorted
array:
	.word 5,18,-12,24,17,1,7,3,-8,20,100,-33

# start and end addresses of array
# (computed taking advantage of labels)
array_N:
	.word array_N-4
array_0:
	.word array


#################
# STACK SEGMENT #
#################

stack:
	.space 4096	# stack able to store 1024 elements should be enough

# our DLX processor does not have hardware support for stack management
# however to implement a recursive function we need a place where to save
# return addresses, input parameters and local variables. therefore we
# reserve this portion of memory to be managed in software as a stack. 


