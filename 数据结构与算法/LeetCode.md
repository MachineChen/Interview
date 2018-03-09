1. Two Sum

Given an array of integers, return indices of the two numbers such that they add up to a specific target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

Example:

Given nums = [2, 7, 11, 15], target = 9,

Because nums[0] + nums[1] = 2 + 7 = 9,
return [0, 1].

public int[] twoSum(int[] nums, int target) {
	int[] result = new int[2];
	Map<Integer, Integer> map = new HashMap<Integer, Integer>();
	for (int i = 0; i < nums.length; i++) {
		//找到另一个目标值
		if (map.containsKey(target - nums[i])) {
			//取下标
			result[0] = i;
			result[1] = map.get(target - nums[i]);
			break;
		}
		map.put(nums[i], i);
	}
	return result;
}

======================================================

2. Add Two Numbers

You are given two non-empty linked lists representing two non-negative integers. The digits are stored in reverse order and each of their nodes contain a single digit. Add the two numbers and return it as a linked list.

You may assume the two numbers do not contain any leading zero, except the number 0 itself.

Example

Input: (2 -> 4 -> 3) + (5 -> 6 -> 4)
Output: 7 -> 0 -> 8
Explanation: 342 + 465 = 807.

public class Solution {
	public ListNode addTwoNumbers(ListNode l1, ListNode l2) {
		ListNode dunmy = new ListNode(-1);
		ListNode cur = dunmy;
		int extra = 0;
		//注意进位时循环
		while (l1 != null || l2 != null || extra > 0) {
			int sum = (l1 == null ? 0 : l1.val) + (l2 == null ? 0 : l2.val) + extra;
			extra = sum / 10;
			sum = sum % 10;
			//注意l1 l2为空的情况
			l1 = l1 == null ? null : l1.next;
			l2 = l2 == null ? null : l2.next;
			ListNode tmp = new ListNode(sum);
			cur.next = tmp;
			cur = tmp;
		}
		return dunmy.next;
	}
}

class ListNode {
	int val;
	ListNode next;
	ListNode(int x) { val = x; }
}

======================================================

3. Longest Substring Without Repeating Characters

Given a string, find the length of the longest substring without repeating characters.

Examples:

Given "abcabcbb", the answer is "abc", which the length is 3.

Given "bbbbb", the answer is "b", with the length of 1.

Given "pwwkew", the answer is "wke", with the length of 3. Note that the answer must be a substring, "pwke" is a subsequence and not a substring.

public static int lengthOfLongestSubstring(String s) {
	int result = 0;
	Map<Character, Integer> map = new HashMap<Character, Integer>();
	for (int i = 0, j = 0; i < s.length(); i++) {
		if (map.containsKey(s.charAt(i))) {
			//这一步非常巧妙，j的含义是遍历到i位置时之前的非重复位置点
			j = Math.max(j, map.get(s.charAt(i)) + 1);
		}
		map.put(s.charAt(i), i);
		result = Math.max(result, i - j + 1);
	}
	return result;
}

======================================================

4. Median of Two Sorted Arrays

There are two sorted arrays nums1 and nums2 of size m and n respectively.

Find the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).

Example 1:

nums1 = [1, 3]
nums2 = [2]

The median is 2.0

Example 2:

nums1 = [1, 2]
nums2 = [3, 4]

The median is (2 + 3)/2 = 2.5


